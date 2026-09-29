#!/usr/bin/env ruby

require "digest"

version, tag, archive_dir, formula_path = ARGV
abort "usage: update-frame.rb VERSION TAG ARCHIVE_DIR FORMULA_PATH" unless ARGV.length == 4
abort "invalid version" unless version.match?(/\A\d+\.\d+\.\d+\z/)
abort "tag must match version" unless tag == "frame-v#{version}"

targets = %w[darwin-arm64 darwin-x64 linux-arm64 linux-x64]
checksums = targets.to_h do |target|
  archive = File.join(archive_dir, "frame-#{version}-#{target}.tar.gz")
  abort "missing archive: #{archive}" unless File.file?(archive) && File.size?(archive)
  [target, Digest::SHA256.file(archive).hexdigest]
end

def source(version, tag, target, sha)
  <<~RUBY.chomp
    url "https://github.com/elydelva/frame/releases/download/#{tag}/frame-#{version}-#{target}.tar.gz"
    sha256 "#{sha}"
  RUBY
end

formula = <<~RUBY
  class Frame < Formula
    desc "Decision-first project management CLI for Git repositories"
    homepage "https://github.com/elydelva/frame"
    version "#{version}"
    license "MIT"

    on_macos do
      on_arm do
        #{source(version, tag, "darwin-arm64", checksums.fetch("darwin-arm64")).gsub("\n", "\n      ")}
      end
      on_intel do
        #{source(version, tag, "darwin-x64", checksums.fetch("darwin-x64")).gsub("\n", "\n      ")}
      end
    end

    on_linux do
      on_arm do
        #{source(version, tag, "linux-arm64", checksums.fetch("linux-arm64")).gsub("\n", "\n      ")}
      end
      on_intel do
        #{source(version, tag, "linux-x64", checksums.fetch("linux-x64")).gsub("\n", "\n      ")}
      end
    end

    def install
      bin.install "frame"
    end

    test do
      assert_equal version.to_s, shell_output("\#{bin}/frame --version").strip
      assert_match(/Usage:/, shell_output("\#{bin}/frame --help"))
    end
  end
RUBY

File.write(formula_path, formula)
