<!-- PROJECT -->
<br />
<div align="center">

  <h3 align="center">livereloadjs-bash</h3>

  <p align="center">
    Reload your webpages using unix tools
    <br />
  </p>
</div>


<!-- ABOUT THE PROJECT -->
## About The Project

There are many ways to reload a webpage when doing web development, It usually uses the framework provided tool (webpack, hugo, ...), they all use [livereload.js](https://github.com/livereload/livereload-js) on the browser side.

livereloadjs-bash is a shell script that uses [miniserve](miniserve), [websocat]() and [inotify-tools]() to implement minimal livereloadjs server.


![Alt text](./birdview.svg?sanitize=true)
<img src="./birdview.svg?sanitize=true">


<!-- GETTING STARTED -->
## Getting Started

The easiest way to get started is to use the docker image:

```
# Replace WEB_PATH with the path of your web files
docker run --rm -ti --name 'livereloadjs-bash' -p 8080:8080 -p 34729:34729 -v "WEB_PATH:/www" izissise/livereloadjs-bash
```

you can also use `livereload.sh` directly.

Once running, write your files as you normally do, every times you save, the page should reload.

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.
