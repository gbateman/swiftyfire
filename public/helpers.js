let editor;

const loadCodeMirrorTextArea = function() {
  const textArea = document.getElementById('text_area');
  editor = CodeMirror.fromTextArea(textArea, {
    lineNumbers: true,
    theme: "swiftyfire"
  });
};

const submitTextArea = function() {
  if (editor) {
    const request = new XMLHttpRequest();
    request.onreadystatechange = function() {
      if (request.readyState == 4 && request.status == 200) {
        console.log('response: ' + request.response);
        window.location.replace(window.location + '/download/' + request.response.id);
      }
    }
    request.open('POST', '/', true);
    request.setRequestHeader("Content-Type", "application/json");
    request.send(JSON.stringify({json: editor.getValue()}));
  }
}
