if [[ "$(_os)" == "macos" ]]; then
  # subshell-elimination: uncomment in case of issues with the static locations
  # export JAVA_8_HOME="$(/usr/libexec/java_home -v 1.8)"
  export JAVA_8_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_191.jdk/Contents/Home"
  # export JAVA_14_HOME="$(/usr/libexec/java_home -v 14)"
  export JAVA_14_HOME="/Library/Java/JavaVirtualMachines/openjdk-14.0.2.jdk/Contents/Home"
fi

alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java14='export JAVA_HOME=$JAVA_14_HOME'

# default to Java 14
java14
# java8
