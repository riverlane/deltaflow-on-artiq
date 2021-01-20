#!/bin/bash
set -x

# hotfix for noisy ubuntu container
export DEBIAN_FRONTEND=noninteractive

#################### INSTALLS #################################################

apt-get update
apt-get -y install pandoc python3 python3-pip rsync -y

ln -s /usr/bin/python3 /usr/bin/python
ln -s /usr/bin/pip3 /usr/bin/pip

pip install --upgrade pip
pip install --no-cache-dir -r ./environment/dev_requirements.txt

export PYTHONPATH=${PYTHONPATH}:/workdir:/workdir/deltalanguage:/workdir/deltasimulator
echo ${PYTHONPATH}

#################### DECLARE VARIABLES ########################################

# In order to add a new version to docs
# add it to DOCSVERSIONS following a whitespace
# Make sure dev is the last one as it has the latest version of conf.py
# TODO: automate this process
DOCSVERSIONS="v0.3.3 dev"
export DOCSVERSIONS=${DOCSVERSIONS}
# This variable is defined in docs/Makefile
# TODO: remover redundant repetition
BUILDDIR="_build"
export BUILDDIR=${BUILDDIR}

pwd
ls -lah
export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)

# make a new temp dir which will be our GitHub Pages docroot
docroot=`mktemp -d`

export REPO_NAME="${GITHUB_REPOSITORY##*/}"

#################### BUILD DOCS ###############################################

# cleanup any old builds
make -C docs clean

for CURRENT_VERSION in ${DOCSVERSIONS}; do
   # for conf.py
   export CURRENT_VERSION
   git checkout ${CURRENT_VERSION}

   echo "INFO: Building for ${CURRENT_VERSION}"

   if [ ! -e 'docs/conf.py' ]; then
      echo "ERROR: Cannot find 'docs/conf.py'"
      exit 1
   fi

   # build HTML / PDF / EPUB
   # TODO: fix PDF build and add here
   make -C docs html
   # make -C docs pdf
   # make -C docs epub

   # copy them to docroot
   mkdir -p "${docroot}/${CURRENT_VERSION}"
   rsync -av "docs/${BUILDDIR}/html/" "${docroot}/${CURRENT_VERSION}/"
   # cp "docs/${BUILDDIR}/pdf/target.pdf" \
   #    "${docroot}/${CURRENT_VERSION}/${REPO_NAME}-docs-${CURRENT_VERSION}.pdf"
   # cp "docs/${BUILDDIR}/epub/target.epub" \
   #    "${docroot}/${CURRENT_VERSION}/${REPO_NAME}-docs-${CURRENT_VERSION}.epub"
   cp "docs/sphinx-build-html.log" "${docroot}/${CURRENT_VERSION}/"
   # cp "docs/sphinx-build-pdf.log" "${docroot}/${CURRENT_VERSION}/"
   # cp "docs/sphinx-build-epub.log" "${docroot}/${CURRENT_VERSION}/"

   make -C docs clean
done

# come back to dev for the lates configuration files if needed
git checkout dev

#################### Update GitHub Pages ######################################

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"

pushd "${docroot}"

# don't bother maintaining history; just generate fresh
git init
git remote add deploy "https://token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git checkout -b gh-pages

# add .nojekyll to the root so that github won't 404 on content added to dirs
# that start with an underscore (_), such as our "_content" dir..
touch .nojekyll

# add redirect from the docroot to our default docs version
cat > index.html <<EOF
<!DOCTYPE html>
<html>
   <head>
      <title>${REPO_NAME} docs</title>
      <meta http-equiv = "refresh" content="0; url='/${REPO_NAME}/dev/'" />
   </head>
   <body>
      <p>Please wait while you're redirected to our <a href="/${REPO_NAME}/dev/">documentation</a>.</p>
   </body>
</html>
EOF

# Add README
cat > README.md <<EOF
# GitHub Pages Cache

You are on the automatically generated branch with public documentation.

If you're looking to update our documentation, check the relevant development
branches.

For more information on how this documentation is built using Sphinx,
Read the Docs, and GitHub Actions/Pages, see:
https://tech.michaelaltfield.net/2020/07/18/sphinx-rtd-github-pages-1
EOF

# copy the resulting html pages built from sphinx above to our new git repo
git add .

# commit all the new files
msg="Updating Docs for commit ${GITHUB_SHA} made on `date -d"@${SOURCE_DATE_EPOCH}" --iso-8601=seconds` from ${GITHUB_REF} by ${GITHUB_ACTOR}"
git commit -am "${msg}"

# overwrite the contents of the gh-pages branch on our github.com repo
git push deploy gh-pages --force

# return to main repo sandbox root
popd

# exit cleanly
exit 0
