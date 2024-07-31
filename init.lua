local M = {}

function M:peek()
    local cache = ya.file_cache(self)
    if not cache then
        return
    end
    if self:preload() == 1 then
        ya.image_show(cache, self.area)
        ya.preview_widgets(self, {})
    end
end

function M:seek(units)
    local h = cx.active.current.hovered
    if h and h.url == self.file.url then
        local step = ya.clamp(-1, units, 1)
        ya.manager_emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = self.file.url })
    end
end

function M:preload()
    local cache = ya.file_cache(self)
    if not cache or fs.cha(cache) then
        return 1
    end

    local output = Command("mutool")
        :args({
            "draw",
            "-I",
            "-F", "png",
            "-r", "75",
            "-o", "-",
            tostring(self.file.url),
            tostring(self.skip + 1)
        })
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :output()

    if output and output.status:success() then
        return fs.write(cache, output.stdout) and 1 or 2
    else
        ya.manager_emit("peek", { math.max(0, self.skip), only_if = self.file.url })
    end
end

return M
