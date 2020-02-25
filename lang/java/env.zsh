if [[ "$(_os)" == "macos" ]]; then
  export JAVA_8_HOME="$(/usr/libexec/java_home -v 1.8)"
  export JAVA_13_HOME="$(/usr/libexec/java_home -v 13)"
fi

alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java13='export JAVA_HOME=$JAVA_13_HOME'

# default to Java 13
java13
