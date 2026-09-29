class Frame < Formula
  desc "Decision-first project management CLI for Git repositories"
  homepage "https://github.com/elydelva/frame"
  version "0.1.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/elydelva/frame/releases/download/frame-v0.1.1/frame-0.1.1-darwin-arm64.tar.gz"
      sha256 "64aeb8564aae6975c17558d8fb5a3baedad477914c8130ef84fb492a5217901f"
    end
    on_intel do
      url "https://github.com/elydelva/frame/releases/download/frame-v0.1.1/frame-0.1.1-darwin-x64.tar.gz"
      sha256 "89d2e6485c971cbd3df02fc693b602778265ca1c1a045957d78b4ad1f14d0ef9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/elydelva/frame/releases/download/frame-v0.1.1/frame-0.1.1-linux-arm64.tar.gz"
      sha256 "3ef1155989153a435c286ca38b330c17fba60375253d6913a87a498ad15a6ac5"
    end
    on_intel do
      url "https://github.com/elydelva/frame/releases/download/frame-v0.1.1/frame-0.1.1-linux-x64.tar.gz"
      sha256 "0462a4e3770ad7f2ec2386542b8cc3b2d38ce55ff99f940d059fc8a5962e57d7"
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
