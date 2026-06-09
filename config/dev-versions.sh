# Preferred development tool targets for bootstrap scripts.
#
# DNF-managed tools use package names or ordered candidate package names because
# Fedora owns the exact package version. Put the preferred package first.

PREFERRED_NODE_PACKAGE=nodejs
PREFERRED_NPM_PACKAGE=npm
PREFERRED_PYTHON_PACKAGE=python3
PREFERRED_JAVA_PACKAGE=java-21-openjdk
PREFERRED_GO_PACKAGE=golang
PREFERRED_KOTLIN_SDKMAN_CANDIDATE=kotlin

NODE_PACKAGE_CANDIDATES=("$PREFERRED_NODE_PACKAGE")
NPM_PACKAGE_CANDIDATES=("$PREFERRED_NPM_PACKAGE")

JAVA_PACKAGE_CANDIDATES=(
  "$PREFERRED_JAVA_PACKAGE"
  java-latest-openjdk
  java-openjdk
)

GO_PACKAGE_CANDIDATES=("$PREFERRED_GO_PACKAGE")

PYTHON_DEV_PACKAGES=(
  "$PREFERRED_PYTHON_PACKAGE"
  python3-pip
  python3-devel
  python3-virtualenv
  python3-pytest
  python3-ruff
)

SHELL_DEV_PACKAGES=(
  ShellCheck
)

KOTLIN_SDKMAN_CANDIDATE="$PREFERRED_KOTLIN_SDKMAN_CANDIDATE"
VSCODE_PACKAGE=code

VSCODE_EXTENSIONS=(
  dbaeumer.vscode-eslint
  esbenp.prettier-vscode
  ms-python.python
  charliermarsh.ruff
  golang.Go
  vscjava.vscode-java-pack
  fwcd.kotlin
  ms-azuretools.vscode-docker
  ms-vscode-remote.remote-containers
  redhat.vscode-yaml
  tamasfe.even-better-toml
  eamodio.gitlens
)
