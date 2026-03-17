class Heald < Formula
  desc "Self-healing macOS system daemon — monitors, repairs, and reports"
  homepage "https://github.com/maf4711/heald"
  url "https://github.com/maf4711/heald/releases/download/v1.3.1/heald"
  sha256 "881f44ee58b4293b9aa7311099d2c5ee9a5dc6b96d3513a9b6ca7e0fa7a4a138"
  version "1.3.1"
  license "MIT"

  depends_on :macos
  depends_on arch: :arm64

  def install
    bin.install "heald"

    # Download support files from repo
    system "curl", "-sL", "-o", "com.heald.daemon.plist",
      "https://raw.githubusercontent.com/maf4711/heald/v1.3.1/launchd/com.heald.daemon.plist"
    system "curl", "-sL", "-o", "install.sh",
      "https://raw.githubusercontent.com/maf4711/heald/v1.3.1/install.sh"
    system "curl", "-sL", "-o", "uninstall.sh",
      "https://raw.githubusercontent.com/maf4711/heald/v1.3.1/uninstall.sh"
    system "curl", "-sL", "-o", "heald-top",
      "https://raw.githubusercontent.com/maf4711/heald/main/heald-top"
    system "curl", "-sL", "-o", "heald-top-render.py",
      "https://raw.githubusercontent.com/maf4711/heald/main/heald-top-render.py"

    prefix.install "com.heald.daemon.plist"
    prefix.install "install.sh"
    prefix.install "uninstall.sh"
    bin.install "heald-top"
    bin.install "heald-top-render.py"

    chmod 0755, bin/"heald"
    chmod 0755, bin/"heald-top"
    chmod 0755, bin/"heald-top-render.py"
  end

  def post_install
    (var/"log/heald").mkpath
  end

  def caveats
    <<~EOS
      To start heald:

        #{prefix}/install.sh

      Or manually:

        cp #{prefix}/com.heald.daemon.plist ~/Library/LaunchAgents/
        sed -i '' "s|YOUR_API_KEY_HERE|47110815|g" ~/Library/LaunchAgents/com.heald.daemon.plist
        launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.heald.daemon.plist

      Terminal dashboard (like top):
        heald-top

      Web dashboard: https://heald.merados.com
      Logs: log stream --predicate 'subsystem=="com.heald.daemon"' --level info
    EOS
  end

  test do
    assert_match "heald", shell_output("#{bin}/heald --version 2>&1", 0)
  end
end
