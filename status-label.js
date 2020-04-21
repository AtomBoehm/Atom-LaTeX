/** @babel */
/** @jsx etch.dom */

import etch from 'etch'
import MessageCount from './message-count'

export default class StatusLabel {
  constructor (properties = {}) {
    this.properties = properties
    this.properties.isActive = false
    etch.initialize(this)
  }

  async destroy () {
    if (this.tooltip) {
      this.tooltip.dispose()
    }
    await etch.destroy(this)
  }

  render () {
    if (this.properties.isActive) {
        return (
          <div className={this.getClassNames()} onclick={() => latex.log.show()}>
            <span className='icon icon-sync busy' />
            <a href='#'>LaTeX</a>
            <MessageCount type='error' />
            <MessageCount type='warning' />
            <MessageCount type='info' />
          </div>
        )
    } else {
        return <div></div>
    }
  }

  getClassNames () {
    const className = `latex-status inline-block`

    if (this.properties.busy) {
      return `${className} is-busy`
    }

    return className
  }

  update (properties = {}) {
    if (properties) {
        Object.assign(this.properties, properties)
    }
    
    return etch.update(this)
  }
  
  setActive () {
      this.properties.isActive = true
  }
  
  
  setInactive () {
      this.properties.isActive = false
  }

  readAfterUpdate () {
    if (this.tooltip) {
      this.tooltip.dispose()
      this.tooltip = null
    }
    this.tooltip = atom.tooltips.add(this.element, { title: 'Click to show LaTeX log' })
  }
}
