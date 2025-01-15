import { bundle } from 'luabundle'
import { writeFileSync } from 'fs'

// Get the output file path from command line arguments
const args = process.argv.slice(2);
const outputFilePath = args[0] || './bundle.lua';

const bundledLua = bundle('./src/main.lua', {
  luaVersion: '5.3',
  force: true,
  paths: [
    'lib/share/lua/5.3/?.lua',
    '?.lua',
    './.?lua',
    './**?.lua',
    './**/**?.lua',
    './**/**/**?.lua',
    './**/**/**/**?.lua',
    './**/**/**/**/**?.lua',
    '?',
    './.?',
    './**?',
    './**/**?',
    './**/**/**?',
    './**/**/**/**?',
    './**/**/**/**/**?'
  ]
})

writeFileSync(outputFilePath, bundledLua)