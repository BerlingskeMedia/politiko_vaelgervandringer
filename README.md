# Voter Migrations

The purpose of this application is to provide a simple, interactive graph
showing the number of voters joining and leaving a particular Danish political
party.

Statistical data is provided by [Gallup](http://www.gallup.com/home.aspx), and
received as JSON data that currently needs to be manually edited a bit before it
can be processed by the application.

The application itself is hosted live in the following AWS S3 bucket;

```
/bem-upload-bdk/upload/tcarlsen/voter-transitions/
```


## Requirements

- Node.js v4.x
- Angular.js 1.x


## Preview

![preview](https://cloud.githubusercontent.com/assets/145288/4613124/17cc0b74-52d2-11e4-9fc9-42a9b6ad0de6.png)


## Contribute

```bash
$ git clone https://github.com/tcarlsen/voter-transitions && cd voter-transitions
$ npm install && bower install
```

## Develop

The development process probably works best by opening up two terminal windows
and running these two commands, respectively;

```bash
1. gulp serve
2. gulp build
```

The command `gulp watch`, although more convenient, doesn't currently work.

There's also a method for working with the application while it's embedded in a
page as it will be on the website, but this has yet to be documented.

## License

This code may only be used on [politiko.dk](http://www.politiko.dk) unless
special rights have been granted.
