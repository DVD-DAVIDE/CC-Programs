--[[
Basic installer script.
Basically copy-pasted from SquidDev-CC/artist

BSD-3-Clause license:
    Copyright 2018-2022 SquidDev

    Redistribution and use in source and binary forms, with or without modification,
    are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its contributors
    may be used to endorse or promote products derived from this software without
    specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
    THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


local files = {
    "door/auth.lua",
    "door/controller.lua",
    "door/hash.lua",
    "door/init.lua",
    "door/installer.lua",
    "door/logger.lua",
    "door/login_interfaces.lua"
}

local tasks = {}
for i, path in ipairs(files) do
    tasks[i] = function()
        local req, err = http.get(
            "https://raw.githubusercontent.com/DVD-DAVIDE/CC-Programs/refs/heads/main/reconnectedcc/" .. path)
        if not req then error("Failed to download " .. path .. ": " .. err, 0) end

        local file = fs.open("door/" .. path, "w")
        file.write(req.readAll())
        file.close()
        req.close()
    end
end

parallel.waitForAll(table.unpack(tasks))

io.open("start.lua", "w"):write('require("door")'):close()

print("Installation complete! Run /start.lua to start.")
