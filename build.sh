# Build the .love package (a .zip)
cd src; zip "../toasty.love" -r *; cd ..

# Run love.js on the project - this will create a new folder with the love.js assets
npx love.js "toasty.love" "docs" -t "toasty" -c

# Copy the template assets to the love.js project
cp template.html "docs/index.html"
