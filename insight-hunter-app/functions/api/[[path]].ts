import { Hono } from 'hono'
import { z } from 'zod'
import { zValidator } from '@hono/zod-validator'

const app = new Hono().basePath('/api')

app.get('/health', (c) => c.json({ ok: true, service: 'insight-hunter' }))
app.get('/demo/summary', (c) => c.json([
  {label:'MRR', value:'$6,400'},
  {label:'Active Workspaces', value:'41'},
  {label:'Reports / wk', value:'183'}
]))
app.get('/demo/forecast', (c) => c.json([
  {month:'Sep',cashIn:28000,cashOut:21000,netCash:7000,eomBalance:42000},
  {month:'Oct',cashIn:29500,cashOut:21900,netCash:7600,eomBalance:49600}
]))

// Content-Type guard for JSON bodies
app.use('*', async (c, next) => {
  const m = c.req.method.toUpperCase()
  if (m === 'POST' || m === 'PUT' || m === 'PATCH') {
    const ct = c.req.header('content-type') || ''
    if (!ct.toLowerCase().includes('application/json')) {
      return c.json({ ok: false, error: 'Unsupported Media Type (expect application/json)' }, 415)
    }
  }
  await next()
})

const headerAuthSchema = z.object({ 'x-api-key': z.string().min(20) })
const reportCreateSchema = z.object({
  name: z.string().min(3).max(64),
  period: z.enum(['M','Q','Y']),
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  includeForecast: z.boolean().default(false),
}).strict()

app.post('/reports',
  zValidator('header', headerAuthSchema, (r, c) => { if (!r.success) return c.json({ ok:false, error:r.error.flatten() }, 401) }),
  zValidator('json', reportCreateSchema, (r, c) => { if (!r.success) return c.json({ ok:false, error:r.error.flatten() }, 400) }),
  async (c) => {
    const body = c.req.valid('json')
    return c.json({ ok:true, reportId: crypto.randomUUID(), input: body })
  }
)

app.onError((_err, c) => c.json({ ok:false, error:'Internal Server Error' }, 500))

export const onRequest = async (ctx: any) => {
  const url = new URL(ctx.request.url)
  if (!url.pathname.startsWith('/api')) {
    // let the static app handle non-API routes
    // @ts-ignore
    return ctx.next()
  }
  try {
    return await app.fetch(ctx.request, ctx.env, ctx.context)
  } catch {
    return new Response(JSON.stringify({ ok:false, error:'Unhandled exception' }), {
      status:500, headers:{'content-type':'application/json'}
    })
  }
}
