update_version <- function(path='.') {
  con <- file('DESCRIPTION')#
  on.exit(close(con))

  desc_content <- readLines(con)
  version_idx  <- which(startsWith(desc_content, 'Version:'))
  date_idx  <- which(startsWith(desc_content, 'Date:'))
  # browser()
  desc_content[version_idx] <- paste('Version:', clean_version_number(get_describe_head()))
  desc_content[date_idx] <- paste('Date:', date())
  writeLines(desc_content, con = con)
}

current_version <- function(path='.') {
  con <- file('DESCRIPTION')
  on.exit(close(con))

  desc_content <- readLines(con)
  version_idx  <- which(startsWith(desc_content, 'Version:'))
  current_version <- unlist(strsplit(desc_content[version_idx], split=': ', fixed = T))[2]
  return(current_version)
}

get_describe_head <- function() {
  if(!dir.exists('.git')){stop("Can't find .git directory in specified path")}
  system2(command="git", args="describe HEAD --tags | rev | sed 's/g-/./' | sed 's/-/+/' | rev", stdout=T)
}

clean_version_number <- function(ver_num) {
  spl_ver_num <- unlist(strsplit(ver_num, split='+', fixed = T))
  ver_num <- spl_ver_num[1]
  commit_num <- unlist(strsplit(spl_ver_num[2], split='.', fixed = T))[1]
  commit_num <- ifelse(!is.na(commit_num),paste0('-', commit_num), '')
  return(paste0(ver_num, commit_num))
}
