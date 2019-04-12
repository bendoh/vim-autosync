" Make sure we're running VIM version 8 or higher.
if v:version < 800
  echoerr 'AutoSync requires VIM version 8 or higher'
elseif !exists('g:asyncProjectRoot') || !exists('g:asyncPattern') || !exists('g:asyncWebRoot')
  echoerr 'Need g:asyncProjectRoot, g:asyncPattern and g:asyncWebRoot set'
endif

" Automatic syncing when working remotely
let s:AsyncBufferName = 'AutoSyncResults'

" This callback will be executed when the entire command is completed
function! autosync#finish(channel)
  let b:asyncUploadingStatus=''
  redraws!
  unlet s:syncjob
endfunction

function! autosync#background(command)
  
  if exists('s:syncjob')
    echo 'Already running task in background'
  else
    let b:asyncUploadingStatus=" Uploading... "
    redraws!
    let s:syncCommand = a:command
    let s:syncjob = job_start(a:command, {'close_cb': 'autosync#finish', 'in_io': 'null', 'err_io': 'buffer', 'err_name': s:AsyncBufferName, 'out_io': 'buffer', 'out_name': s:AsyncBufferName, 'out_msg': 0 })
  endif
endfunction

function! autosync#sync()
  let l:relativePath = strcharpart(expand('%:p'), len(g:asyncProjectRoot))
  call autosync#background("scp " . g:asyncProjectRoot . l:relativePath . " " . g:asyncWebRoot . l:relativePath)
endfunction

function! autosync#enable()
  augroup AutoSync
    autocmd!
    execute "autocmd BufWritePost " . g:asyncPattern . " call autosync#sync()"
    echo "Enabled AutoSync for files matching " . g:asyncPattern
  augroup END
endfunction
command! EnableAutoSync call autosync#enable()

function! autosync#disable()
  augroup AutoSync
   autocmd!
  augroup END

  echo "Disabled AutoSync"
endfunction
command! DisableAutoSync call autosync#disable()
