require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "digest"

class UpdateFrameTest < Minitest::Test
  SCRIPT = File.expand_path("update-frame.rb", __dir__)
  TARGETS = %w[darwin-arm64 darwin-x64 linux-arm64 linux-x64].freeze

  def test_generates_four_immutable_urls_and_checksums
    Dir.mktmpdir do |dir|
      TARGETS.each do |target|
        File.write(File.join(dir, "frame-1.2.3-#{target}.tar.gz"), target)
      end
      formula = File.join(dir, "frame.rb")
      output, status = Open3.capture2e("ruby", SCRIPT, "1.2.3", "frame-v1.2.3", dir, formula)
      assert status.success?, output
      text = File.read(formula)
      assert_includes text, 'version "1.2.3"'
      assert_operator text.index('version "1.2.3"'), :<, text.index('license "MIT"')
      TARGETS.each do |target|
        assert_includes text, "https://github.com/elydelva/frame/releases/download/frame-v1.2.3/frame-1.2.3-#{target}.tar.gz"
        assert_includes text, Digest::SHA256.hexdigest(target)
      end
      assert_includes text, 'bin.install "frame"'
    end
  end

  def test_rejects_missing_archive_without_writing_formula
    Dir.mktmpdir do |dir|
      formula = File.join(dir, "frame.rb")
      _output, status = Open3.capture2e("ruby", SCRIPT, "1.2.3", "frame-v1.2.3", dir, formula)
      refute status.success?
      refute File.exist?(formula)
    end
  end
end
