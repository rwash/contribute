CKEDITOR.editorConfig = function( config )
{
  config.toolbar_Custom = [
    { name: 'tools',       items : [ 'Maximize' ] },
    { name: 'clipboard',   items : [ 'Undo','Redo' ] },
    { name: 'insert',      items : [ 'Image','Table','HorizontalRule','SpecialChar' ] },
    { name: 'paragraph',   items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-'] },
    { name: 'alignment',   items : [ 'JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-' ] },
    { name: 'links',       items : [ 'Link','Unlink' ] },
    '/',
    { name: 'basicstyles', items : [ 'Bold','Italic','Underline','Strike','Blockquote','-','RemoveFormat' ] },
    { name: 'styles',      items : [ 'Format','Font','FontSize' ] },
    { name: 'colors',      items : [ 'TextColor','BGColor' ] }
  ];
  config.toolbar = 'Custom';
}
