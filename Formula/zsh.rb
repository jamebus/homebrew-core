class Zsh < Formula
  desc "UNIX shell (command interpreter)"
  homepage "http://www.zsh.org/"
  url "https://downloads.sourceforge.net/project/zsh/zsh/5.2/zsh-5.2.tar.gz"
  mirror "http://www.zsh.org/pub/zsh-5.2.tar.gz"
  sha256 "fa924c534c6633c219dcffdcd7da9399dabfb63347f88ce6ddcd5bb441215937"

  bottle do
    sha256 "079cc9661532edf75b4602fffcf900d3d23a1f143f35ca3cce93a37c0fbc6ae8" => :el_capitan
    sha256 "385e57d2ef3e6ef24925a64cbaaf85d1776d8d466ef366223d7b599583fbaddf" => :yosemite
    sha256 "932fe97487753363d3ddd683918210367ec29104e700001bbf5cd18c2f4d59fa" => :mavericks
  end

  head do
    url "git://git.code.sf.net/p/zsh/code"
    depends_on "autoconf" => :build
  end

  option "without-etcdir", "Disable the reading of Zsh rc files in /etc"

  deprecated_option "disable-etcdir" => "without-etcdir"

  depends_on "gdbm"
  depends_on "pcre"

  def install
    system "Util/preconfig" if build.head?

    args = %W[
      --prefix=#{prefix}
      --enable-fndir=#{share}/zsh/functions
      --enable-scriptdir=#{share}/zsh/scripts
      --enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions
      --enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts
      --enable-runhelpdir=#{share}/zsh/help
      --enable-cap
      --enable-maildir-support
      --enable-multibyte
      --enable-pcre
      --enable-zsh-secure-free
      --with-tcsetpgrp
    ]

    if build.without? "etcdir"
      args << "--disable-etcdir"
    else
      args << "--enable-etcdir=/etc"
    end

    system "./configure", *args

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    if build.head?
      # disable target install.man, because the required yodl comes neither with OS X nor Homebrew
      # also disable install.runhelp and install.info because they would also fail or have no effect
      system "make", "install.bin", "install.modules", "install.fns"
    else
      system "make", "install"
      system "make", "install.info"
    end
  end

  def caveats; <<-EOS.undent
    In order to use this build of zsh as your login shell,
    it must be added to /etc/shells.
    Add the following to your zshrc to access the online help:
      unalias run-help
      autoload run-help
      HELPDIR=#{HOMEBREW_PREFIX}/share/zsh/help
    EOS
  end

  test do
    assert_equal "homebrew\n",
      shell_output("#{bin}/zsh -c 'echo homebrew'")
  end
end
