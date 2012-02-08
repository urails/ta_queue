def escp str
  str.replace(CGI::escapeHTML(str))
end
