class Frame < Formula
  desc "Decision-first project management CLI for Git repositories"
  homepage "https://github.com/elydelva/frame"
  version "0.1.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/elydelva/frame/releases/download/frame-v0.1.2/frame-0.1.2-darwin-arm64.tar.gz"
      sha256 "6f52aed493874c5a871934a3760d01ad69b3495cc421405a305fc9c1579cdf18"
    end
    on_intel do
      url "https://github.com/elydelva/frame/releases/download/frame-v0.1.2/frame-0.1.2-darwin-x64.tar.gz"
      sha256 "67a7ff7d8765b5f65b497d7515cb664026775dcdd3734da2329f47168b19c03c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/elydelva/frame/releases/download/frame-v0.1.2/frame-0.1.2-linux-arm64.tar.gz"
      sha256 "2a587a20f8fadb2cc92ee4d557ce1ca6443af26076bb9ffcfd5cd52811eff06b"
    end
    on_intel do
      url "https://github.com/elydelva/frame/releases/download/frame-v0.1.2/frame-0.1.2-linux-x64.tar.gz"
      sha256 "0a494cbadb418662541a7691fdae6ad00aed5d728569c5b5d0dffa6755618c0c"
    end
  end

  def install
    bin.install "frame"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/frame --version").strip
    assert_match(/Usage:/, shell_output("#{bin}/frame --help"))
  end
end
