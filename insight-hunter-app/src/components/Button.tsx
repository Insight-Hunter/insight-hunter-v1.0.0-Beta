import React, { ButtonHTMLAttributes, useRef } from 'react'
type Props = ButtonHTMLAttributes<HTMLButtonElement> & { variant?: 'primary'|'outline'|'ghost'|'danger'|'success'; size?: 'sm'|'md'|'lg'; loading?: boolean }
export default function Button({ variant='primary', size='md', loading=false, children, className='', onClick, ...rest }: Props) {
  const ref = useRef<HTMLButtonElement>(null)
  const handleClick: React.MouseEventHandler<HTMLButtonElement> = (e) => {
    const el = ref.current
    if (el) {
      const rect = el.getBoundingClientRect()
      const ripple = document.createElement('span'); ripple.className='ripple'
      ripple.style.left = `${e.clientX-rect.left}px`; ripple.style.top = `${e.clientY-rect.top}px`
      el.appendChild(ripple); setTimeout(() => ripple.remove(), 620)
    }
    onClick?.(e)
  }
  const v = variant ? `btn-${variant}` : ''
  const s = size === 'lg' ? 'btn-lg' : size === 'sm' ? 'btn-sm' : ''
  return (<button ref={ref} onClick={handleClick} className={['btn', v, s, className].join(' ')} {...rest}>
    {loading ? <span className='skeleton' style={{width:16,height:16,borderRadius:999}}/> : children}
  </button>)
}
