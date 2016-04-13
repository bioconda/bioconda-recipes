local channels = {"bioconda", "r"}

---- 

local builddir = 'involucro-build'
local repo = VAR.namespace .. '/' .. VAR.package .. ':' .. VAR.version

local channelArgs = ""
for i, c in pairs(channels) do
  channelArgs = channelArgs .. "--channel " .. c .. " "
end


local condaBinds = {
  builddir .. "/dist:/usr/local",
}

inv.task('all')
  .runTask('build')
  .runTask('package')
  .runTask('push')
  .runTask('clean')

inv.task('build')
  .using('continuumio/miniconda:latest')
    .withConfig({entrypoint = {"/bin/sh", "-c"}})
    .withHostConfig({binds = {builddir .. "/dist:/usr/local"}})
    .run('conda install ' .. channelArgs .. '-p /usr/local --copy --yes ' .. VAR.package .. '=' .. VAR.conda_version)

inv.task('package')
  .wrap(builddir .. '/dist').at('/usr/local')
    .inImage('progrium/busybox:latest')
    .as(repo)

inv.task('push')
  .push(repo)

inv.task('clean')
  .using('continuumio/miniconda:latest')
    .withHostConfig({binds = {builddir .. ':/data'}})
    .run('rm', '-rf', '/data/dist')
