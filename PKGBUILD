# Maintainer: Your Name <you@example.com>
# Repository layout must have: scripts/*, bashd, bashd-init.sh at archive root.
# When using GitHub releases, archive extracts to RepoName-pkgver (e.g. Bashd-0.1.0).

pkgname=bashd
pkgver=0.1.0
pkgrel=1
pkgdesc="Bulk data management toolkit for Linux — bash scripts for file/directory cleanup, transfer, and organization"
arch=('any')
url="https://github.com/terpinedream/Bashd"
license=('custom')
depends=('bash')
optdepends=('figlet: pretty headers for bashd --<command>')
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v${pkgver}.tar.gz")
# If packaging from a repo without tags, use a commit or branch tarball, e.g.:
# source=("$url/archive/refs/heads/main.tar.gz" and adjust _builddir)
# Extracted dir name from GitHub archive is typically RepoName-pkgver (e.g. Bashd-0.1.0)
_repo="Bashd"
sha256sums=('SKIP')

package() {
  _bd="${srcdir}/${_repo}-${pkgver}"
  # Fallback: try repo name with hyphen (e.g. Bashd-AUR) or first dir in srcdir
  if [[ ! -d "$_bd" ]]; then
    _bd="${srcdir}/Bashd-AUR-${pkgver}"
  fi
  if [[ ! -d "$_bd" ]]; then
    _bd=$(find "$srcdir" -maxdepth 1 -type d ! -path "$srcdir" | head -1)
  fi

  # All scripts and main entry into /usr/bin
  install -d "${pkgdir}/usr/bin"
  for _s in cleanme cram crush bfold ufold namechange pull stick flatten nest hop trim prefix dedupe archive bak pullfrom pushto dotsync topd paclock; do
    install -Dm755 "${_bd}/scripts/${_s}" "${pkgdir}/usr/bin/${_s}"
  done
  install -Dm755 "${_bd}/bashd" "${pkgdir}/usr/bin/bashd"

  # Init script for crush/hop (source from profile.d or manually)
  install -d "${pkgdir}/usr/share/bashd"
  install -Dm644 "${_bd}/bashd-init.sh" "${pkgdir}/usr/share/bashd/bashd-init.sh"

  # Login shells: load crush/hop automatically
  install -d "${pkgdir}/etc/profile.d"
  printf '%s\n' '[ -f /usr/share/bashd/bashd-init.sh ] && . /usr/share/bashd/bashd-init.sh' > "${pkgdir}/etc/profile.d/bashd.sh"
  chmod 644 "${pkgdir}/etc/profile.d/bashd.sh"
}
