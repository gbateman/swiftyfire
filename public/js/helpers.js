let editor;

const loadCodeMirrorTextArea = function() {
  const textArea = document.getElementById('text_area');
  editor = CodeMirror.fromTextArea(textArea, {
    lineNumbers: true,
    theme: "swiftyfire"
  });
};
