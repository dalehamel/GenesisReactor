# Monkey-patch async sinatra to support all verb sinatra supports
# Can remove if this patch gets merged:
# https://github.com/raggi/async_sinatra/pull/39
module Sinatra
  # Monkey patch async to add some more methods
  module Async
    def apatch(path, opts = {}, &bk)
      aroute('PATCH', path, opts, &bk)
    end

    def alink(path, opts = {}, &bk)
      aroute('LINK', path, opts, &bk)
    end

    def aunlink(path, opts = {}, &bk)
      aroute('UNLINK', path, opts, &bk)
    end
  end
end
