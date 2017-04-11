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
  exec('mkdir download/' + request.params.id, function(error, stdout, stderr) {
    const path = 'download/' + request.params.id + '/';
    if (!error) {
      exec('echo \'' + request.body.text_area + '\' >> ' + path + 'Object.json',
        function(error, stdout, stderr) {
          if (!error) {
            console.log('swift/SwiftyFire/' + systemPrefix + 'SwiftyFire < ' + path + 'Object.json > ' + path + 'Object.swift');
            exec('swift/SwiftyFire/' + systemPrefix + 'SwiftyFire < ' + path + 'Object.json > ' + path + 'Object.swift',
              function(error, stdout, stderr) {
                if (!error) {
                  response.download(path + 'Object.swift', 'Object.swift');
                  exec('rm -rf ' + path, function(error, stdout, stderr) {});
                }
              });
          }
        });
    }
  });
});

app.listen(app.get('port'), function() {
  console.log('App is running on port: ', app.get('port'));
});

function submitButtonAction() {
  const textArea = document.getElementById('main_area');
  const input = textArea.innerHTML;
}
