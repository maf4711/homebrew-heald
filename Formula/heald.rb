class Heald < Formula
  desc "Self-healing macOS system daemon — monitors, repairs, and reports"
  homepage "https://github.com/maf4711/heald"
  url "https://github.com/maf4711/heald/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "3cf0bc02372bce727801fd26f410ae6ed26456d93c5a9ac819eed90fae3f97ad"
  license "MIT"

  depends_on :macos
  depends_on xcode: ["16.0", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/heald"

    # Install LaunchAgent plist template and scripts
    prefix.install "launchd/com.heald.daemon.plist"
    prefix.install "install.sh"
    prefix.install "uninstall.sh"
  end

  def post_install
    (var/"log/heald").mkpath
  end

  def caveats
    <<~EOS
      To start heald as a LaunchAgent:

        # Copy and configure plist
        cp #{prefix}/com.heald.daemon.plist ~/Library/LaunchAgents/
        sed -i '' "s|USERNAME|$(whoami)|g" ~/Library/LaunchAgents/com.heald.daemon.plist
        sed -i '' "s|YOUR_API_KEY_HERE|<your-key>|g" ~/Library/LaunchAgents/com.heald.daemon.plist

        # Load the daemon
        launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.heald.daemon.plist

      Or use the bundled install script:
        #{prefix}/install.sh

      Optionally install Ollama for AI-powered decisions:
        brew install ollama
        ollama pull qwen3-coder:30b

      Dashboard: https://heald.merados.com
      Logs: log stream --predicate 'subsystem=="com.heald.daemon"' --level info
    EOS
  end

  test do
    assert_match "heald", shell_output("#{bin}/heald --version 2>&1", 0)
  end
end
