#!/usr/bin/env bash
###################################################
# Usage: ./create.sh [--clean] [--install]
###################################################

# set -euo pipefail
set -eo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

CI=true
DEBUG=${DEBUG:-}
ROOT_DIR=$(pwd)
npm_install=false

if [ -n "$DEBUG" ]; then
  echo "> Debug mode enabled <"
  echo "Running script as user: $(id -u -n):$(id -g -n)"
fi
if [ "$1" == "--clean" ] || [ "$2" == "--clean" ]; then
  echo "Cleaning existing samples..."

  # Remove all folders except .devcontainer and .git
  find . -mindepth 1 -maxdepth 1 -type d -not -name ".devcontainer" -not -name ".git" -exec rm -rf {} \;
fi
if [ "$1" == "--install" ] || [ "$2" == "--install" ]; then
  npm_install=true
fi

# gen <base_dir> <name> <command> [<create_dir>] [<dir_to_rename>]
gen() {
  base_dir=$1
  name=$2
  cmd=$3
  mk_dir=$4
  rename_dir=$5
  mkdir -p "$base_dir"
  pushd "$base_dir" > /dev/null
  if [ -d "$name" ]; then
    echo "Skipping $name (already exists)"
    return
  fi
  echo "Generating $base_dir/$name..."
  if [ "$mk_dir" == true ]; then
    mkdir "$name"
    pushd "$name" > /dev/null
  else
    pushd . > /dev/null
  fi
  if [ -z "$DEBUG" ]; then
    eval "$cmd" > /dev/null
  else
    eval "$cmd"
  fi
  rm -rf .git || true
  if [ "$npm_install" == true ]; then
    npm install || true
  fi
  popd > /dev/null
  if [ -n "$rename_dir" ]; then
    mv "$rename_dir" "$name"
  fi
  popd > /dev/null
}

# autoenter <command>
autoenter() {
  expect -c "
    set timeout -1
    spawn $*
    expect {
      -re \"\[?\]\" { send \"\r\"; exp_continue }
    }"
}

# nofail <command>
nofail() {
  eval "$1" || true
}

npx() {
  command npx -y "$@"
}

#########################################
# Web frameworks
#########################################

# Vanilla HTML
gen vanilla vanilla-html "echo '<!doctype html><html><body>Hello world</body></html>' > index.html" true
gen vanilla vanilla-vite "npx create-vite@latest vanilla-vite --template vanilla-ts"

# Angular
gen angular angular "npx @angular/cli@latest new angular --defaults --skip-git --skip-install"
gen angular angular-minimal "npx @angular/cli@latest new angular-minimal --defaults --skip-git --skip-install --minimal --strict --standalone --style css --routing false --skip-tests --inline-style --inline-template"
gen angular angular-scully "npx @angular/cli@latest new angular-scully --defaults --skip-git --skip-install --minimal && cd angular-scully && nofail \"npx @angular/cli@latest add --skip-confirmation --defaults @scullyio/init@latest\" --force"
# angular-ssr
# gen angular angular-analog "npx create-analog@latest"
# gen angular angular-universal "npx @angular/cli@latest new angular-universal --defaults --skip-git --skip-install --minimal && cd angular-universal && npx @angular/cli@latest add --skip-confirmation --defaults @nguniversal/express-engine"
# gen ionic-angular "autoenter npx -y @ionic/cli@latest start ionic-angular blank --type angular --no-deps --no-git"

# React
# gen react "npx create-react-app@latest react-app" false react-app
gen react react-vite "npx create-vite@latest react-vite --template react-ts"
# gen gatsby "GATSBY_LOGGER=yurnalist npx create-gatsby@latest -y --no-color gatsby"
# gen ionic-react "autoenter npx -y @ionic/cli@latest start ionic-react blank --type react --no-deps --no-git"
# gen astro-react "npx degit withastro/astro/examples/framework-react#latest astro-react"
# gen nextjs "npx create-next-app@latest nextjs --use-npm"
# gen remix "autoenter npx -y create-remix@latest remix --no-install"
# gen react-static "npx react-static@latest create -n react-static -t basic"
# gen docusaurus "npx create-docusaurus@latest docusaurus classic --skip-install"

# Vue
gen vue vue "npx create-vue@latest vue --default"
gen vue vue-vite "npx create-vite@latest vue-vite --template vue-ts"
gen vue nuxtjs "npx create-nuxt-app@latest nuxtjs --answers '{\"name\":\"nuxt\",\"language\":\"ts\",\"pm\":\"npm\",\"ui\":\"none\",\"target\":\"static\",\"features\":[],\"linter\":[],\"test\":\"none\",\"mode\":\"universal\",\"devTools\":[]}'"
gen vue vuepress "autoenter npx -y create-vuepress-site@latest vuepress"
# gen vitepress "npm init -y && npm i -D vitepress && mkdir docs && echo '# Hello VitePress' > docs/index.md && node -p $'JSON.stringify({ ...require(\'./package.json\'), scripts: { \'docs:dev\': \'vitepress dev docs\', \'docs:build\': \'vitepress build docs\', \'docs:serve\': \'vitepress serve docs\' }}, null, 2)' > package.json.new && mv package.json.new package.json" true
# gen ionic-vue "autoenter npx -y @ionic/cli@latest start ionic-vue blank --type vue --no-deps --no-git"
# gen astro-vue "npx degit withastro/astro/examples/framework-vue#latest astro-vue"

# Svelte
gen svelte svelte "autoenter npx create-svelte@latest svelte"
gen svelte svelte-vite "npx create-vite@latest svelte-vite --template svelte-ts"
# gen astro-svelte "npx degit withastro/astro/examples/framework-svelte#latest astro-svelte"

# Lit
gen lit lit "npx degit lit/lit-element-starter-ts lit"
gen lit lit-vite "npx create-vite@latest lit-vite --template lit-ts"
gen lit lit-owc "npx @open-wc/create@latest --type scaffold --scaffoldType app --typescript true --tagName lit-app --installDependencies false --features --writeToDisk true" false lit-app
gen lit lit-astro "npx degit withastro/astro/examples/framework-lit#latest lit-astro"

# Solid
gen solid solid "npx degit solidjs/templates/ts solid"
gen solid solid-start "autoenter npx create-solid@latest solid-start --solid-start"
gen solid solid-vite "npx create-vite@latest solid-vite --template solid-ts"

# Qwik
gen qwik qwik "npx create-qwik@latest basic qwik"
gen qwik qwik-vite "npx create-vite@latest qwik-vite --template qwik-ts"

# Other
# gen docsify "npx docsify-cli@latest init docsify"


# Non-JS


# jquery
# knockout
# durandal

# gen preact "npx preact-cli@latest create default preact"
# gen aurelia "npx aurelia-cli@latest new aurelia --select"
# gen ember "npx ember-cli@latest new ember-app --lang en --skip-git true --skip-npm true" false ember-app
# gen riot "autoenter npx -y create-riot@latest riot" true
# gen stencil "npx create-stencil@latest app stencil"
# gen polymer "npx degit PolymerLabs/polymer-3-first-element polymer && cd polymer && cp -f demo/index.html ./ && sed -i 's/..\/node/.\/node/g' index.html && sed -i 's/demo-element.js/demo\/demo-element.js/g' index.html"
# gen hexo "npx hexo-cli@latest init hexo"
# gen capacitor "npx @capacitor/create-app@latest capacitor --name capacitor --app-id com.fw.playground"
# gen hugo "hugo new site hugo && cd hugo && git init && git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke && echo 'theme = \"ananke\"' >> config.toml && hugo new posts/my-first-post.md && echo 'Hello world' >> content/posts/my-first-post.md"
# gen elm "yes | elm init && curl https://raw.githubusercontent.com/elm/elm-lang.org/master/examples/buttons.elm -o src/Main.elm" true
# gen blazor-wasm "dotnet new blazorwasm -o blazor-wasm --no-https"
# gen flutter "flutter create flutterapp" false flutterapp
# gen jekyll "jekyll new jekyll"
# gen slate "npx degit slatedocs/slate slate && cd slate && bundle install"
# gen mkdocs "mkdocs new mkdocs"
# gen eleventy "npm init -y && npm i -D @11ty/eleventy && echo '<!doctype html><html><head><title>Page title</title></head><body><p>Hi</p></body></html>' > index.html && echo '# Page header' > README.md" true
# gen astro "npx degit withastro/astro/examples/starter#latest astro"
# gen astro-alpine "npx degit withastro/astro/examples/framework-alpine#latest astro-alpine"
# gen astro-preact "npx degit withastro/astro/examples/framework-preact#latest astro-preact"
# gen astro-solid "npx degit withastro/astro/examples/framework-solid#latest astro-solid"
# gen astro-multiple "npx degit withastro/astro/examples/framework-multiple#latest astro-multiple"
# gen pelican "$ROOT_DIR/expect/pelican.exp && printf 'Title: My First Post\nDate: 2022-04-20 12:20\nCategory: Blog\n\nHello world' > content/my-post.md" true
# gen gridsome "npx @gridsome/cli@latest create gridsome"
# gen solid "npx degit solidjs/templates/ts solid"
# gen sapper "npx degit sveltejs/sapper-template#rollup sapper"
# gen metalsmith "npx degit metalsmith/metalsmith/examples/static-site metalsmith"
# gen wintersmith "npx wintersmith@latest new wintersmith"
# gen middleman "middleman init middleman"
# gen brunch "npx degit brunch/with-es6 brunch"
# gen mdbook "autoenter mdbook init --force --ignore git --theme --title mdbook mdbook"
# gen zola "autoenter zola init zola && cd zola && mkdir -p content/blog && printf '+++\ntitle = \"Hello\"\n+++\n# Hello Zola' > content/blog/_index.md && git clone https://github.com/InputUsername/zola-hook.git themes/hook && echo -e 'theme = \"hook\"\n' > config.tmp && cat config.toml >> config.tmp && mv config.tmp config.toml"
# gen lektor "$ROOT_DIR/expect/lektor.exp"
# gen vite-preact "npx create-vite@latest vite-preact --template preact --variant javascript"

# gen django "django-admin startproject djangoapp" false djangoapp

#########################################
# App frameworks (Server Side Rendering)
#########################################

# gen marko "autoenter npx -y @marko/create@latest marko"
# gen meteor "meteor create --blaze meteor --allow-superuser" # build: meteor build --directory dist
# gen blazor-server "dotnet new blazorserver -o blazor-server --no-https"
