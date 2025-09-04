-- CFM Bot Questions Seed Data
-- 40 Questions for Cofounder Matching
-- Created: 2025-09-04

-- Clear existing data
TRUNCATE TABLE questions CASCADE;
TRUNCATE TABLE question_batches CASCADE;

-- ==========================================
-- QUESTION BATCHES
-- ==========================================

INSERT INTO question_batches (batch_number, batch_name, description, min_questions, max_questions, order_index) VALUES
(1, 'Основная информация', 'Базовые вопросы о роли и опыте', 5, 7, 1),
(2, 'Рабочий стиль', 'Предпочтения в работе и коммуникации', 5, 7, 2),
(3, 'Ценности и культура', 'Личные ценности и корпоративная культура', 5, 7, 3),
(4, 'Стратегия и видение', 'Бизнес-стратегия и долгосрочные цели', 5, 7, 4),
(5, 'Навыки и экспертиза', 'Технические и софт-скиллы', 5, 7, 5),
(6, 'Финансы и риски', 'Отношение к финансам и рискам', 5, 5, 6);

-- ==========================================
-- BATCH 1: ОСНОВНАЯ ИНФОРМАЦИЯ (7 вопросов)
-- ==========================================

INSERT INTO questions (batch_number, order_index, question_text, question_key, answer_type, options, category, weight, is_critical) VALUES
(1, 1, 'Какова ваша основная роль в команде?', 'team_role', 'choice',
 '[{"value":1,"text":"🔧 Технический лидер (CTO)"},
  {"value":2,"text":"💼 Бизнес-развитие (CEO)"},
  {"value":3,"text":"🎨 Продукт и дизайн (CPO)"},
  {"value":4,"text":"📊 Операции и финансы (COO/CFO)"}]'::jsonb,
'role', 2.0, true),

(1, 2, 'Сколько лет опыта в стартапах?', 'startup_experience', 'choice',
'[{"value":1,"text":"0-2 года"},
  {"value":2,"text":"3-5 лет"},
  {"value":3,"text":"5-10 лет"},
  {"value":4,"text":"10+ лет"}]'::jsonb,
'experience', 1.5, false),

(1, 3, 'Готовность к full-time работе?', 'commitment_level', 'choice',
'[{"value":1,"text":"Готов сразу full-time"},
  {"value":2,"text":"Могу начать part-time"},
  {"value":3,"text":"Пока только evenings/weekends"},
  {"value":4,"text":"Нужно время на переход"}]'::jsonb,
'commitment', 1.8, true),

(1, 4, 'Предпочитаемая индустрия?', 'preferred_industry', 'choice',
'[{"value":1,"text":"FinTech"},
  {"value":2,"text":"HealthTech"},
  {"value":3,"text":"EdTech"},
  {"value":4,"text":"B2B SaaS"}]'::jsonb,
'industry', 1.2, false),

(1, 5, 'Предпочтения по финансированию?', 'funding_preference', 'choice',
'[{"value":1,"text":"Bootstrapping"},
  {"value":2,"text":"Ангельские инвестиции"},
  {"value":3,"text":"Венчурный капитал"},
  {"value":4,"text":"Гранты и субсидии"}]'::jsonb,
'funding', 1.3, false),

(1, 6, 'Локация для работы?', 'work_location', 'choice',
'[{"value":1,"text":"Полностью удаленно"},
  {"value":2,"text":"Гибрид (офис + удаленка)"},
  {"value":3,"text":"Только офис"},
  {"value":4,"text":"Готов к релокации"}]'::jsonb,
'location', 1.4, false),

(1, 7, 'Опыт привлечения инвестиций?', 'fundraising_experience', 'choice',
'[{"value":1,"text":"Нет опыта"},
  {"value":2,"text":"Пытался, но не удалось"},
  {"value":3,"text":"Привлекал до $100k"},
  {"value":4,"text":"Привлекал $100k+"}]'::jsonb,
'experience', 1.1, false);

-- ==========================================
-- BATCH 2: РАБОЧИЙ СТИЛЬ (7 вопросов)
-- ==========================================

INSERT INTO questions (batch_number, order_index, question_text, question_key, answer_type, options, category, weight, is_critical) VALUES
(2, 1, 'Предпочитаемый стиль принятия решений?', 'decision_style', 'choice',
'[{"value":1,"text":"Консенсус команды"},
  {"value":2,"text":"Данные и метрики"},
  {"value":3,"text":"Интуиция и опыт"},
  {"value":4,"text":"Быстрые эксперименты"}]'::jsonb,
'workstyle', 1.5, false),

(2, 2, 'Как вы относитесь к риску?', 'risk_tolerance', 'choice',
'[{"value":1,"text":"Минимизирую риски"},
  {"value":2,"text":"Умеренный риск"},
  {"value":3,"text":"Готов рисковать"},
  {"value":4,"text":"Высокий риск = высокая награда"}]'::jsonb,
'personality', 1.6, true),

(2, 3, 'Рабочий график?', 'work_schedule', 'choice',
'[{"value":1,"text":"9-6 стабильно"},
  {"value":2,"text":"Гибкий график"},
  {"value":3,"text":"Готов к овертаймам"},
  {"value":4,"text":"24/7 стартап режим"}]'::jsonb,
'workstyle', 1.3, false),

(2, 4, 'Стиль коммуникации?', 'communication_style', 'choice',
'[{"value":1,"text":"Асинхронная (сообщения)"},
  {"value":2,"text":"Видеозвонки"},
  {"value":3,"text":"Личные встречи"},
  {"value":4,"text":"Микс всего"}]'::jsonb,
'communication', 1.2, false),

(2, 5, 'Подход к конфликтам?', 'conflict_resolution', 'choice',
'[{"value":1,"text":"Избегаю конфликтов"},
  {"value":2,"text":"Дипломатия и компромисс"},
  {"value":3,"text":"Прямой разговор"},
  {"value":4,"text":"Данные решают споры"}]'::jsonb,
'personality', 1.4, false),

(2, 6, 'Скорость vs Качество?', 'speed_vs_quality', 'choice',
'[{"value":1,"text":"Качество превыше всего"},
  {"value":2,"text":"Баланс 50/50"},
  {"value":3,"text":"Скорость важнее"},
  {"value":4,"text":"Зависит от контекста"}]'::jsonb,
'workstyle', 1.5, false),

(2, 7, 'Размер идеальной команды?', 'ideal_team_size', 'choice',
'[{"value":1,"text":"2-3 человека"},
  {"value":2,"text":"4-6 человек"},
  {"value":3,"text":"7-10 человек"},
  {"value":4,"text":"10+ человек"}]'::jsonb,
'preferences', 1.1, false);

-- ==========================================
-- BATCH 3: ЦЕННОСТИ И КУЛЬТУРА (7 вопросов)
-- ==========================================

INSERT INTO questions (batch_number, order_index, question_text, question_key, answer_type, options, category, weight, is_critical) VALUES
(3, 1, 'Что важнее всего в компании?', 'company_values', 'choice',
'[{"value":1,"text":"Инновации и технологии"},
  {"value":2,"text":"Клиентский сервис"},
  {"value":3,"text":"Команда и культура"},
  {"value":4,"text":"Прибыль и рост"}]'::jsonb,
'values', 1.7, true),

(3, 2, 'Прозрачность в команде?', 'transparency_level', 'choice',
'[{"value":1,"text":"Полная открытость"},
  {"value":2,"text":"Важное обсуждаем"},
  {"value":3,"text":"Need-to-know basis"},
  {"value":4,"text":"Иерархия информации"}]'::jsonb,
'culture', 1.4, false),

(3, 3, 'Work-life balance?', 'work_life_balance', 'choice',
'[{"value":1,"text":"Строгое разделение"},
  {"value":2,"text":"Здоровый баланс"},
  {"value":3,"text":"Работа - приоритет"},
  {"value":4,"text":"Стартап = жизнь"}]'::jsonb,
'lifestyle', 1.5, false),

(3, 4, 'Отношение к неудачам?', 'failure_attitude', 'choice',
'[{"value":1,"text":"Учусь на ошибках"},
  {"value":2,"text":"Fail fast, learn faster"},
  {"value":3,"text":"Минимизирую риски провала"},
  {"value":4,"text":"Неудача = новые возможности"}]'::jsonb,
'mindset', 1.3, false),

(3, 5, 'Социальная ответственность?', 'social_responsibility', 'choice',
'[{"value":1,"text":"Это основа бизнеса"},
  {"value":2,"text":"Важно, но не приоритет"},
  {"value":3,"text":"Сначала прибыль"},
  {"value":4,"text":"Зависит от индустрии"}]'::jsonb,
'values', 1.1, false),

(3, 6, 'Корпоративная культура?', 'corporate_culture', 'choice',
'[{"value":1,"text":"Семейная атмосфера"},
  {"value":2,"text":"Профессиональная"},
  {"value":3,"text":"Стартап-драйв"},
  {"value":4,"text":"Меритократия"}]'::jsonb,
'culture', 1.4, false),

(3, 7, 'Мотивация в работе?', 'work_motivation', 'choice',
'[{"value":1,"text":"Изменить мир"},
  {"value":2,"text":"Финансовый успех"},
  {"value":3,"text":"Самореализация"},
  {"value":4,"text":"Решение проблем"}]'::jsonb,
'personality', 1.5, false);

-- ==========================================
-- BATCH 4: СТРАТЕГИЯ И ВИДЕНИЕ (6 вопросов)
-- ==========================================

INSERT INTO questions (batch_number, order_index, question_text, question_key, answer_type, options, category, weight, is_critical) VALUES
(4, 1, 'Горизонт планирования?', 'planning_horizon', 'choice',
'[{"value":1,"text":"3-6 месяцев"},
  {"value":2,"text":"1 год"},
  {"value":3,"text":"3-5 лет"},
  {"value":4,"text":"10+ лет"}]'::jsonb,
'strategy', 1.4, false),

(4, 2, 'Стратегия роста?', 'growth_strategy', 'choice',
'[{"value":1,"text":"Органический рост"},
  {"value":2,"text":"Агрессивное масштабирование"},
  {"value":3,"text":"Стабильность и прибыль"},
  {"value":4,"text":"M&A и партнерства"}]'::jsonb,
'strategy', 1.6, true),

(4, 3, 'Exit стратегия?', 'exit_strategy', 'choice',
'[{"value":1,"text":"IPO"},
  {"value":2,"text":"Продажа корпорации"},
  {"value":3,"text":"Долгосрочный бизнес"},
  {"value":4,"text":"Не думаю об этом"}]'::jsonb,
'strategy', 1.3, false),

(4, 4, 'Целевая аудитория?', 'target_audience', 'choice',
'[{"value":1,"text":"B2C массовый рынок"},
  {"value":2,"text":"B2B enterprise"},
  {"value":3,"text":"B2B SMB"},
  {"value":4,"text":"B2G государство"}]'::jsonb,
'market', 1.2, false),

(4, 5, 'Конкурентное преимущество?', 'competitive_advantage', 'choice',
'[{"value":1,"text":"Технологии и инновации"},
  {"value":2,"text":"Цена и доступность"},
  {"value":3,"text":"Качество и сервис"},
  {"value":4,"text":"Скорость и гибкость"}]'::jsonb,
'strategy', 1.5, false),

(4, 6, 'Подход к конкурентам?', 'competitor_approach', 'choice',
'[{"value":1,"text":"Игнорирую, делаю свое"},
  {"value":2,"text":"Учусь у них"},
  {"value":3,"text":"Агрессивная конкуренция"},
  {"value":4,"text":"Сотрудничество возможно"}]'::jsonb,
'mindset', 1.1, false);

-- ==========================================
-- BATCH 5: НАВЫКИ И ЭКСПЕРТИЗА (7 вопросов)
-- ==========================================

INSERT INTO questions (batch_number, order_index, question_text, question_key, answer_type, options, category, weight, is_critical) VALUES
(5, 1, 'Ваша суперсила?', 'superpower', 'choice',
'[{"value":1,"text":"Техническая экспертиза"},
  {"value":2,"text":"Продажи и нетворкинг"},
  {"value":3,"text":"Продуктовое видение"},
  {"value":4,"text":"Операционная эффективность"}]'::jsonb,
'skills', 1.8, true),

(5, 2, 'Слабая сторона?', 'weakness', 'choice',
'[{"value":1,"text":"Технические навыки"},
  {"value":2,"text":"Продажи и презентации"},
  {"value":3,"text":"Управление людьми"},
  {"value":4,"text":"Финансы и юриспруденция"}]'::jsonb,
'skills', 1.4, false),

(5, 3, 'Опыт управления командой?', 'management_experience', 'choice',
'[{"value":1,"text":"Нет опыта"},
  {"value":2,"text":"1-5 человек"},
  {"value":3,"text":"6-20 человек"},
  {"value":4,"text":"20+ человек"}]'::jsonb,
'experience', 1.3, false),

(5, 4, 'Техническая грамотность?', 'tech_literacy', 'choice',
'[{"value":1,"text":"Могу кодить"},
  {"value":2,"text":"Понимаю технологии"},
  {"value":3,"text":"Базовые знания"},
  {"value":4,"text":"Гуманитарий"}]'::jsonb,
'skills', 1.2, false),

(5, 5, 'Опыт в продажах?', 'sales_experience', 'choice',
'[{"value":1,"text":"Продавал лично"},
  {"value":2,"text":"Управлял продажами"},
  {"value":3,"text":"Есть понимание"},
  {"value":4,"text":"Нет опыта"}]'::jsonb,
'experience', 1.2, false),

(5, 6, 'Знание английского?', 'english_level', 'choice',
'[{"value":1,"text":"Native/Fluent"},
  {"value":2,"text":"Advanced"},
  {"value":3,"text":"Intermediate"},
  {"value":4,"text":"Basic"}]'::jsonb,
'skills', 1.1, false),

(5, 7, 'Нетворкинг способности?', 'networking_ability', 'choice',
'[{"value":1,"text":"Широкая сеть контактов"},
  {"value":2,"text":"Хорошие связи в индустрии"},
  {"value":3,"text":"Небольшой круг"},
  {"value":4,"text":"Интроверт"}]'::jsonb,
'skills', 1.3, false);

-- ==========================================
-- BATCH 6: ФИНАНСЫ И РИСКИ (6 вопросов)
-- ==========================================

INSERT INTO questions (batch_number, order_index, question_text, question_key, answer_type, options, category, weight, is_critical) VALUES
(6, 1, 'Готовность инвестировать свои деньги?', 'personal_investment', 'choice',
'[{"value":1,"text":"Готов инвестировать значительно"},
  {"value":2,"text":"Небольшую сумму"},
  {"value":3,"text":"Только время"},
  {"value":4,"text":"Ищу зарплату сразу"}]'::jsonb,
'finance', 1.7, true),

(6, 2, 'Финансовая подушка?', 'financial_runway', 'choice',
'[{"value":1,"text":"6+ месяцев"},
  {"value":2,"text":"3-6 месяцев"},
  {"value":3,"text":"1-3 месяца"},
  {"value":4,"text":"Живу от зарплаты"}]'::jsonb,
'finance', 1.5, false),

(6, 3, 'Распределение equity?', 'equity_split', 'choice',
'[{"value":1,"text":"Равные доли"},
  {"value":2,"text":"По вкладу"},
  {"value":3,"text":"Vesting 4 года"},
  {"value":4,"text":"Обсудим индивидуально"}]'::jsonb,
'finance', 1.6, true),

(6, 4, 'Отношение к долгам?', 'debt_attitude', 'choice',
'[{"value":1,"text":"Избегаю любых долгов"},
  {"value":2,"text":"Только при необходимости"},
  {"value":3,"text":"Долг = инструмент роста"},
  {"value":4,"text":"Готов рисковать"}]'::jsonb,
'finance', 1.2, false),

(6, 5, 'Минимальная цель по выручке (год)?', 'revenue_target', 'choice',
'[{"value":1,"text":"$100k"},
  {"value":2,"text":"$1M"},
  {"value":3,"text":"$10M"},
  {"value":4,"text":"$100M+"}]'::jsonb,
'goals', 1.4, false),

(6, 6, 'Готовность к pivot?', 'pivot_readiness', 'choice',
'[{"value":1,"text":"Буду держаться до конца"},
  {"value":2,"text":"Если данные покажут"},
  {"value":3,"text":"Готов менять быстро"},
  {"value":4,"text":"Pivot = норма"}]'::jsonb,
'flexibility', 1.3, false);

-- ==========================================
-- VERIFY DATA
-- ==========================================

SELECT 
    'Total Questions' as metric, 
    COUNT(*) as count 
FROM questions
UNION ALL
SELECT 
    'Total Batches' as metric, 
    COUNT(*) as count 
FROM question_batches
UNION ALL
SELECT 
    'Batch ' || batch_number::text as metric,
    COUNT(*) as count
FROM questions
GROUP BY batch_number
ORDER BY metric;