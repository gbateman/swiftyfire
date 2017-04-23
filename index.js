const express = require('express');
const bodyParser = require('body-parser');
const uuid = require('uuid/v4');
const exec = require('child_process').exec;
const fs = require('fs');
const app = express();

const systemPrefix = process.env.NODE_ENV === 'production' ? 'linux-' : '';

app.set('port', process.env.PORT || 5000);

app.use(bodyParser.urlencoded({
  extended: false
}));
app.use(bodyParser.json());

app.use(express.static(__dirname + '/public'));

app.set('views', __dirname + '/views');
app.set('view engine', 'pug');

app.get('/', function(request, response) {
  const id = uuid();
  response.render('index', {
    id
  });
});

app.post('/download/:id', function(request, response) {
  const text = request.body.text_area;
  const name = request.body.name || 'Object';
  exec('mkdir -p download/' + request.params.id, function(error, stdout, stderr) {
    const path = 'download/' + request.params.id + '/';
    if (!error) {
      exec('echo \'' + text + '\' >> ' + path + name + '.json',
        function(error, stdout, stderr) {
          if (!error) {
            exec('swift/SwiftyFire/' + systemPrefix + 'SwiftyFire ' +
              path + name + '.json > ' + path + name + '.swift', {
                env: {
                  'LD_LIBRARY_PATH': __dirname + '/swift/SwiftyFire/linux-libs:/usr/local/lib64/:$LD_LIBRARY_PATH'
                }
              },
              function(error, stdout, stderr) {
                if (!error) {
                  response.download(path + name + '.swift', name + '.swift', function(error) {
                    exec('rm -rf ' + path, function(error, stdout, stderr) {});
                    if (error) {
                      console.log(error);
                    }
                  });
                } else {
                  console.log(error);
                  response.status(400).end();
                }
              });
          } else {
            console.log(error);
            response.status(400).end();
          }
        });
    } else {
      console.log(error);
      response.status(400).end();
    }
  });
});

app.listen(app.get('port'), function() {
  console.log('App is running on port: ', app.get('port'));
});
