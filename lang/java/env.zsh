if [[ "$(_os)" == "macos" ]]; then
  # subshell-elimination: uncomment in case of issues with the static locations
  # export JAVA_8_HOME="$(/usr/libexec/java_home -v 1.8)"
  export JAVA_8_HOME="/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home"
  # export JAVA_14_HOME="$(/usr/libexec/java_home -v 14)"
  export JAVA_LATEST_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home"
fi

alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias javalatest='export JAVA_HOME=$JAVA_LATEST_HOME'

# default to Java 14
javalatest
# java8
