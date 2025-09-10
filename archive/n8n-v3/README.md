# 📦 CFM Bot v3.0 - n8n Implementation (ARCHIVED)

> ⚠️ **This implementation has been archived in favor of the new Next.js architecture.**
> 
> This folder contains the complete n8n-based implementation of CFM Bot v3.0 for historical reference and potential rollback scenarios.

## 📋 Why This Was Archived

After extensive development with n8n, we encountered several limitations:

1. **Performance Issues**
   - 800ms+ response times
   - Limited to 100 requests per second
   - Memory consumption issues

2. **Development Constraints**
   - Difficult debugging in visual workflow
   - 2+ days to implement new features
   - Limited code reusability

3. **Technical Limitations**
   - No proper version control for workflows
   - Cannot implement complex algorithms efficiently
   - Limited testing capabilities

4. **Cost Considerations**
   - $50+/month for hosting
   - Additional costs for scaling

## 📁 Archive Contents

```
n8n-v3/
├── workflows/           # n8n workflow JSON files
│   ├── CFM.1-main-router.json
│   ├── CFM.2-registration.json
│   ├── CFM.3-questions.json
│   └── ...
├── database/           # Database v3.0 structure
│   ├── schema.sql
│   ├── migrations/
│   └── seeds/
├── docs/              # Original documentation
│   ├── ARCHITECTURE.md
│   ├── WORKFLOWS.md
│   └── ...
└── config/            # Configuration files
    └── telegram-webhook.json
```

## 🔄 Migration Path

If you need to reference the old implementation:

1. **Database**: The schema remains compatible
2. **Business Logic**: Ported to `/src/services/`
3. **API Endpoints**: Reimplemented in `/src/app/api/`
4. **Workflows**: Converted to code in `/src/lib/workflows/`

## 📊 What Was Completed in v3.0

- ✅ 38-table database schema
- ✅ Complete documentation
- ✅ Main bot router workflow
- ⚠️ Partial question system (60%)
- ⚠️ Partial user management (70%)
- ❌ Matching engine (not started)
- ❌ Payment system (not started)
- ❌ Analytics (not started)

## 🔗 Useful References

- [Original n8n instance](https://n8n.1int.tech)
- [Workflow ID: 82NNfa65ImefYweQ](https://n8n.1int.tech/workflow/82NNfa65ImefYweQ)
- [Database v3 Schema](database/schema.sql)

## ⚡ Quick Rollback (if needed)

If you need to restore the n8n implementation:

```bash
# 1. Restore database (compatible with both versions)
psql -U postgres -d cfm_database -f archive/n8n-v3/database/schema.sql

# 2. Import workflows to n8n
# Upload JSON files from archive/n8n-v3/workflows/

# 3. Configure webhook
curl -X POST "https://api.telegram.org/bot{TOKEN}/setWebhook" \
  -d '{"url": "https://n8n.1int.tech/webhook/45e44e1c-f611-45e9-94f7-b2247b25b8db"}'
```

---

*This archive is maintained for reference only. Active development continues in the main Next.js implementation.*
