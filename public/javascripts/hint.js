
(function($){$.fn.hint=function(blurClass,blankClass){if(!blurClass)blurClass='blur';if(!blankClass)blankClass='blank';return this.each(function(){var $input=$(this),title=$input.attr('title'),$form=$(this.form),$win=$(window),cursor_timeout;function setBlankHint(){$input.val(title).addClass(blankClass).removeClass(blurClass);cursor_timeout=setTimeout(function(){$input.setCursorPosition(0)},10);}
function remove(){if(this.value===title)
$input.val('').removeClass(blurClass).removeClass(blankClass);}
function onFocus(){if(this.value===title)
setBlankHint();}
function onBlur(){if(this.value==='')
$input.val(title);if(this.value===title)
$input.addClass(blurClass).removeClass(blankClass);}
function onKeyDown(e){var ignored_keys=[8,16,17,18,91,93];if(this.value===title&&!$input.hasClass(blurClass)&&$.inArray(e.keyCode,ignored_keys)==-1){$input.val('').removeClass(blurClass).removeClass(blankClass);}else if(this.value===''){setBlankHint();}}
function onKeyUp(){if(this.value=='')
setBlankHint();}
if(title){if($input.val()==='')$input.val(title);$input.unbind('focus').focus(onFocus).unbind('keydown').keydown(onKeyDown).unbind('keyup').keyup(onKeyUp).unbind('blur').blur(onBlur).blur();$form.submit(remove);$win.unload(remove);}});};$.fn.setCursorPosition=function(pos){this.each(function(index,elem){if(elem.setSelectionRange){elem.setSelectionRange(pos,pos);}else if(elem.createTextRange){var range=elem.createTextRange();range.collapse(true);range.moveEnd('character',pos);range.moveStart('character',pos);range.select();}});return this;};})(jQuery);