# 📝 CFM Bot TODO List v3.0

**Last Updated**: 2025-09-04  
**Sprint**: MVP Development  
**Overall Progress**: 56%

## 🔴 Critical Priority (Blockers)

- [ ] **CFM-001**: Fix n8n node type prefixes ([Issue #6](https://github.com/rivega42/cfm-bot/issues/6))
  - Update all `n8n-nodes-base.` to `nodes-base.`
  - Keep Switch node as-is (do not change type)
  - Test import in n8n v1.108.2
  - **ETA**: 2 hours
  - **Status**: 🔄 In Progress

- [ ] **CFM-002**: Implement inline keyboard support
  - Use HTTP Request instead of Telegram node
  - Create keyboard builder helper
  - Handle callback_query events
  - **ETA**: 4 hours
  - **Status**: ⏳ Queued

## 🟡 Medium Priority (Core Features)

### User Management
- [ ] **CFM-003**: Complete registration flow
  - Multi-type user support (individual/team/project)
  - Profile creation wizard
  - Skill selection interface
  - **ETA**: 6 hours

- [ ] **CFM-004**: Session management
  - Implement TTL on bot_sessions
  - Handle timeouts gracefully
  - State recovery mechanism
  - **ETA**: 3 hours

### Question System
- [ ] **CFM-005**: Implement 3-stage question flow
  - Stage 1: Basic info (Q1-10)
  - Stage 2: Professional (Q11-25)
  - Stage 3: Matching preferences (Q26-40)
  - Progress tracking
  - **ETA**: 8 hours

- [ ] **CFM-006**: Answer validation
  - Input type checking
  - Range validation
  - Required field enforcement
  - **ETA**: 2 hours

### Matching Engine
- [ ] **CFM-007**: Design matching algorithm
  - Define scoring weights
  - Implement compatibility matrix
  - Create ranking system
  - **ETA**: 12 hours

- [ ] **CFM-008**: Build match generation workflow
  - Query eligible users
  - Calculate scores
  - Apply subscription limits
  - **ETA**: 6 hours

## 🟢 Low Priority (Future Features)

### Payment System
- [ ] **CFM-009**: Robokassa integration
  - Setup test credentials
  - Create payment workflow
  - Handle webhooks
  - **ETA**: 8 hours

### Analytics
- [ ] **CFM-010**: Create analytics dashboard
  - User acquisition funnel
  - Match success rates
  - Revenue metrics
  - **ETA**: 10 hours

### Interview System
- [ ] **CFM-011**: HR interview automation
  - Question bank creation
  - AI evaluation integration
  - Result reporting
  - **ETA**: 16 hours

## 📁 Documentation Tasks

- [x] Complete ARCHITECTURE.md
- [ ] Update API.md with all endpoints
- [ ] Create DEPLOYMENT.md guide
- [ ] Write TESTING.md procedures
- [ ] Add inline code comments

## 🧪 Testing Requirements

- [ ] Unit tests for core functions
- [ ] Integration tests for workflows
- [ ] End-to-end bot testing
- [ ] Load testing (1000 users)
- [ ] Security testing

## 🚀 DevOps Tasks

- [ ] Setup CI/CD pipeline
- [ ] Configure monitoring (Grafana)
- [ ] Implement backup strategy
- [ ] Create Docker containers
- [ ] Setup staging environment

## 💡 Ideas & Improvements

- [ ] Voice message support
- [ ] Multi-language support (EN/RU)
- [ ] Web dashboard for users
- [ ] Mobile app development
- [ ] AI chat assistant
- [ ] Video introductions
- [ ] Skill verification system
- [ ] Referral program

## ✅ Completed Tasks

- [x] Database schema v3.0
- [x] Project documentation structure
- [x] GitHub repository setup
- [x] Telegram bot creation
- [x] n8n instance configuration
- [x] Load 40 questions to DB
- [x] Complete ARCHITECTURE.md

## 📊 Sprint Planning

### Week 1 (Current)
- Fix critical n8n issues
- Complete registration flow
- Start question system

### Week 2
- Finish question system
- Design matching algorithm
- Begin match generation

### Week 3
- Complete matching engine
- Start payment integration
- Begin testing phase

### Week 4
- Finish payment system
- Complete all testing
- Deploy MVP version

## 🔗 Resources

- [Project Board](https://github.com/rivega42/cfm-bot/projects)
- [Issues](https://github.com/rivega42/cfm-bot/issues)
- [n8n Docs](https://docs.n8n.io)
- [Telegram Bot API](https://core.telegram.org/bots/api)
- [Robokassa Docs](https://docs.robokassa.ru)

---

**Note**: Tasks are prioritized using MoSCoW method (Must/Should/Could/Won't).  
**Update Frequency**: Daily during active development.  
**Review Cycle**: Weekly sprint planning sessions.