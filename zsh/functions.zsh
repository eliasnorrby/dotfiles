
function new-typescript-project() {
  if [[ $# -eq 0 ]] ; then
      echo 'Error: expected 1 argument'
      exit 1
  fi

  PROJECT_FOLDER=$1
  TEMPLATE_FOLDER="/Users/elias.norrby/Dropbox (FFCG)/folders/dev/CodeIsKing/_projectTemplateFilesTypeScript"

  echo "Creating project folder '$PROJECT_FOLDER'..."
  mkdir $PROJECT_FOLDER

  echo "Copying configuration files from '$TEMPLATE_FOLDER'..."
  cp $TEMPLATE_FOLDER/wallaby.js ./$PROJECT_FOLDER
  cp $TEMPLATE_FOLDER/package.json ./$PROJECT_FOLDER
  cp $TEMPLATE_FOLDER/Jenkinsfile ./$PROJECT_FOLDER
  cp $TEMPLATE_FOLDER/.gitignore ./$PROJECT_FOLDER
  cd $PROJECT_FOLDER

  echo "Creating 'src' and 'test' folders in '$PROJECT_FOLDER'..."
  mkdir test
  mkdir src
  cd -

  echo "Copying 'TemplateTest.ts' to 'test' folder..."
  cp $TEMPLATE_FOLDER/TemplateTest.ts ./$PROJECT_FOLDER/test
  cd -

  echo Running 'npm install'...
  npm install

  echo Running 'npm test' to verify installation...
  npm test

  echo
  echo Done! 
}

