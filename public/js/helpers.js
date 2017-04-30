const loadCodeMirrorTextArea = function() {
  const textArea = document.getElementById('text_area');
  let editor = CodeMirror.fromTextArea(textArea, {
    lineNumbers: true,
    theme: "swiftyfire"
  });
};

loadCodeMirrorTextArea();
