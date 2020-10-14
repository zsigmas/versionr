tryCatch(
  expr = {
    if(!require(versionr)){
      warning('Version not updated, versionr not found')
    }else{
      print(paste('From:', versionr::current_version(), 'to', clean_version_number(versionr::get_describe_head())))
      versionr::update_version()
    }
  },
  error = function(e){
    print(e)
    quit(status=1)
  }
)


