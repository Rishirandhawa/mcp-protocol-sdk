#!/bin/bash

# Deployment script for MCP Protocol SDK
# This script helps with releasing new versions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're on main branch
check_branch() {
    local branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$branch" != "main" ]; then
        print_error "You must be on the main branch to release. Current branch: $branch"
        exit 1
    fi
}

# Check if working directory is clean
check_clean() {
    if [ -n "$(git status --porcelain)" ]; then
        print_error "Working directory is not clean. Please commit or stash changes."
        exit 1
    fi
}

# Check if we're up to date with remote
check_updated() {
    print_step "Checking if branch is up to date..."
    git fetch origin
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse origin/main)
    
    if [ "$local_commit" != "$remote_commit" ]; then
        print_error "Local branch is not up to date with origin/main"
        print_warning "Please run: git pull origin main"
        exit 1
    fi
}

# Run tests
run_tests() {
    print_step "Running comprehensive tests..."
    
    # Test minimal build
    print_step "Testing minimal build (no default features)..."
    cargo check --no-default-features --lib
    
    # Test individual features
    print_step "Testing individual features..."
    cargo check --no-default-features --features stdio
    cargo check --no-default-features --features http
    cargo check --no-default-features --features websocket
    cargo check --no-default-features --features validation
    
    # Test all features
    print_step "Testing all features..."
    cargo test --all-features
    
    # Test examples
    print_step "Testing examples..."
    cargo check --example echo_server --features stdio,tracing-subscriber
    cargo check --example http_server --features http,tracing-subscriber
    cargo check --example websocket_server --features websocket,tracing-subscriber
    
    # Run clippy
    print_step "Running clippy..."
    cargo clippy --all-features -- -D warnings
    
    # Check formatting
    print_step "Checking code formatting..."
    cargo fmt --all -- --check
    
    print_success "All tests passed!"
}

# Build release
build_release() {
    print_step "Building release version..."
    cargo build --release --all-features
    print_success "Release build completed!"
}

# Update version
update_version() {
    local version=$1
    print_step "Updating version to $version..."
    
    # Update Cargo.toml
    sed -i.bak "s/^version = \".*\"/version = \"$version\"/" Cargo.toml
    rm Cargo.toml.bak
    
    # Update CHANGELOG.md
    local date=$(date +%Y-%m-%d)
    sed -i.bak "s/## \[Unreleased\]/## [Unreleased]\n\n## [$version] - $date/" CHANGELOG.md
    rm CHANGELOG.md.bak
    
    print_success "Version updated to $version"
}

# Create git tag
create_tag() {
    local version=$1
    print_step "Creating git tag v$version..."
    
    git add Cargo.toml CHANGELOG.md
    git commit -m "chore: bump version to $version"
    git tag -a "v$version" -m "Release version $version"
    
    print_success "Git tag v$version created"
}

# Publish to crates.io
publish_crate() {
    print_step "Publishing to crates.io..."
    print_warning "This will publish the crate to crates.io. This action cannot be undone!"
    
    read -p "Are you sure you want to publish? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cargo publish
        print_success "Crate published to crates.io!"
    else
        print_warning "Publish cancelled"
        return 1
    fi
}

# Push to GitHub
push_github() {
    local version=$1
    print_step "Pushing to GitHub..."
    
    git push origin main
    git push origin "v$version"
    
    print_success "Pushed to GitHub"
}

# Create GitHub release
create_github_release() {
    local version=$1
    print_step "Creating GitHub release..."
    
    # Extract changelog for this version
    local changelog_content=$(sed -n "/## \[$version\]/,/## \[/p" CHANGELOG.md | head -n -1 | tail -n +2)
    
    gh release create "v$version" \
        --title "Release v$version" \
        --notes "$changelog_content" \
        --latest
    
    print_success "GitHub release created"
}

# Main release function
release() {
    local version=$1
    
    if [ -z "$version" ]; then
        print_error "Please provide a version number"
        echo "Usage: $0 release <version>"
        echo "Example: $0 release 0.2.0"
        exit 1
    fi
    
    print_step "Starting release process for version $version"
    
    # Pre-release checks
    check_branch
    check_clean
    check_updated
    
    # Run tests
    run_tests
    
    # Build release
    build_release
    
    # Update version
    update_version "$version"
    
    # Create tag
    create_tag "$version"
    
    # Publish (optional)
    if publish_crate; then
        # Push to GitHub
        push_github "$version"
        
        # Create GitHub release
        create_github_release "$version"
        
        print_success "🎉 Release $version completed successfully!"
        print_step "The new version is now available on crates.io and GitHub"
    else
        print_warning "Skipped publishing to crates.io"
        print_step "You can publish later with: cargo publish"
    fi
}

# Development helpers
dev_setup() {
    print_step "Setting up development environment..."
    
    # Install useful tools
    rustup component add clippy rustfmt
    cargo install cargo-watch cargo-expand
    
    print_success "Development environment setup complete!"
}

check_release_ready() {
    print_step "Checking if ready for release..."
    
    check_branch
    check_clean
    check_updated
    run_tests
    
    print_success "✅ Ready for release!"
}

# Help
show_help() {
    echo "MCP Protocol SDK Deployment Script"
    echo ""
    echo "Usage:"
    echo "  $0 release <version>     Release a new version"
    echo "  $0 check                 Check if ready for release"
    echo "  $0 dev-setup             Set up development environment"
    echo "  $0 test                  Run all tests"
    echo "  $0 help                  Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 release 0.2.0         Release version 0.2.0"
    echo "  $0 check                 Check release readiness"
}

# Main script
case "${1:-help}" in
    "release")
        release "$2"
        ;;
    "check")
        check_release_ready
        ;;
    "dev-setup")
        dev_setup
        ;;
    "test")
        run_tests
        ;;
    "help"|*)
        show_help
        ;;
esac
