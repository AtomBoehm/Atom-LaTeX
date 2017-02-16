{ Disposable } = require 'atom'
path = require 'path'

latexPattern = /^Output\swritten\son\s(.*)\s\(.*\)\.$/gm
latexFatalPattern = /Fatal error occurred, no output PDF file produced!/gm
latexError = /^(?:(.*):(\d+):|!)(?: (.+) Error:)? (.+?)\.?$/
latexBox = /^((?:Over|Under)full \\[vh]box \([^)]*\)) in paragraph at lines (\d+)--(\d+)$/
latexWarn = /^((?:(?:Class|Package) \S+)|LaTeX) (Warning|Info):\s+(.*?)(?: on input line (\d+))?\.$/

module.exports =
class Parser extends Disposable
  constructor: (latex) ->
    @latex = latex

  parse: (log) ->
    @status = 'check'
    if log.match(latexPattern) or log.match(latexFatalPattern)
      @parseLatex log
    @latex.panel.view.update()

  parseLatex: (log) ->
    log = log.replace(/(.{78}(\w|\s|\d|\\|\/))(\r\n|\n)/g, '$1')
    lines = log.replace(/(\r\n)|\r/g, '\n').split('\n')
    items = []
    for line in lines
      result = line.match latexBox
      if result
        items.push
          type: 'typesetting',
          text: result[1]
          file: @latex.mainFile
          line: parseInt(result[2], 10)
        continue
      result = line.match latexWarn
      if result
        @status = 'alert' if @status isnt 'x'
        items.push
          type: 'warning',
          text: result[3]
          file: @latex.mainFile
          line: parseInt result[4]
        continue
      result = line.match latexError
      if result
        @status = 'x'
        items.push
          type: 'error',
          text: if result[3] and result[3] != 'LaTeX' then \
                """#{result[3]}: #{result[4]}""" else result[4],
          file: if result[1] then \
            path.resolve(path.dirname(@latex.mainFile), result[1]) else \
            @latex.mainFile
          line: if result[2] then parseInt result[2], 10 else undefined
        continue
    @latex.logger.log = @latex.logger.log.concat items
