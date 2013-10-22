CKEDITOR.editorConfig = function( config )
{
  config.toolbar_Custom = [
    { name: 'clipboard',   items : [ 'Undo','Redo' ] },
    { name: 'insert',      items : [ 'Image','Table','HorizontalRule','SpecialChar' ] },
    { name: 'tools',       items : [ 'Maximize' ] },
    '/',
    { name: 'basicstyles', items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
    { name: 'paragraph',   items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-' ] },
    { name: 'links',       items : [ 'Link','Unlink' ] },
    '/',
    { name: 'styles',      items : [ 'Format','Font','FontSize' ] },
    { name: 'colors',      items : [ 'TextColor','BGColor' ] }
  ];
  config.toolbar = 'Custom';
}
