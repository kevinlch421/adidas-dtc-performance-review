# adidas US Sales Channel Strategy Report

## Table of Contents

- [Project Background](#project-background)
- [About the Dataset](#about-the-dataset)
- [Executive Summary](#executive-summary)
  - [Key Insights](#key-insights)
  - [Business Impact](#business-impact)
  - [Recommended Actions](#recommended-actions)
- [Data-Driven Insights](#data-driven-insights)
  - [DTC: Our Main Growth Driver](#dtc-our-main-growth-driver)
  - [Wholesale: Solid Reach, But Slower and Less Profitable](#wholesale-solid-reach-but-slower-and-less-profitable)
  - [Strong Brand Appeal in Women's Categories](#strong-brand-appeal-in-womens-categories)
- [Recommendations](#recommendations)
- [Limitations & Next-Level Data Needs](#limitations--next-level-data-needs)

## Project Background
In the sportswear industry, brands like Adidas have long depended on **wholesale—selling** large quantities to retailers like Foot Locker for broad market coverage. This approach offers good reach and steady sales, but it **limits their control over pricing and brand presentation**.

To gain more control and boost profits per sale, Adidas launched the "Own the Game" strategy in 2021. The core idea is to shift more sales to Direct-to-Consumer (DTC) through our website and owned stores, **bypassing third-party retailers in the process**. However, the big question is: Does this shift pay off?

This report provides straightforward answers using real US sales data from DTC and wholesale, covering Q1 2020 to Q4 2022. It breaks down DTC growth, compares it to wholesale, and highlights where the real profits are coming from.

## About the Dataset
We used one clean dataset: [the adidas US Sales from Kaggle](https://www.kaggle.com/datasets/sagarmorework/adidas-us-sales) (9,641 orders, 2020–2022).  

To optimize for efficiency, the data was restructured into a star schema with 7 tables (main sales fact table plus dimensions like date, product, channel, and region). This reduces memory use and speeds up analysis. In case you care about the SQL to build the database on MySQL, here is a quick guide on building the star schema is here (link).

<img width="1602" height="893" alt="ERD-v2 drawio" src="https://github.com/user-attachments/assets/06bcddc0-f560-408e-a820-f251a2ae4f8c" />

## Executive Summary

### Key Insights and Recommended
- DTC is our top growth driver: +182% revenue since 2020, fueled by +21% more orders and +35% higher average order value (AOV). Prioritize DTC investments to keep this momentum.  
- DTC generates $55M in revenue vs. wholesale's $40M, despite similar volumes—wholesale lags by $15M due to trade discounts. Clean up wholesale partnerships selectively and negotiate better terms with retailers to protect margins.  
- Women's categories lead in both channels, showing we retain strong female customer loyalty through the shift. Keep targeting this segment to maintain our edge.

![executeive-summary-demo](https://github.com/user-attachments/assets/3c2b5253-e938-4315-9524-726496ec61f3)



## Data-Driven Insights

### DTC: Our Main Growth Driver
- US DTC sales (website and owned stores) jumped 182% since 2020, making it the primary engine for expansion.  
- Growth came from +21% more orders and +35% higher AOV (customer spend per purchase).  
- This shows the "Own the Game" strategy is working—customers prefer buying directly from us.

### Wholesale: Solid Reach, But Slower and Less Profitable
- Wholesale involves selling bulk to retailers; it's stable but grows slowly.  
- Despite handling similar order volumes as DTC, it delivers $15M less revenue ($40M vs. $55M) because we sell at discounted wholesale prices.  
- It's great for broad customer access, but profits suffer from trade discounts. Focus on high-value partners to improve this.

### Strong Brand Appeal in Women's Categories
- The strategy builds on existing strengths rather than creating new ones—especially in women's apparel, the top performer in both DTC and wholesale from 2020–2021.  
- High demand across channels proves our dominance in the US women's market: female customers stay loyal regardless of where they shop.

## Recommendations
From the 2020–2022 data, focus on these four actionable steps:

1. **Push DTC as the growth focus**  
   With 182% growth and strong customer pull, ramp up spending on our digital platforms and stores for quicker, higher-margin returns.

2. **Optimize wholesale selectively**  
   It provides visibility and volume, but low profits from discounts hurt us. Phase out poor performers and strengthen ties with those who maintain our pricing and image.

3. **Leverage Women's as a key strength**  
   Top sales in both channels show genuine demand. Launch women-specific initiatives DTC-first to drive excitement, while supplying basics to solid wholesale accounts.

4. **Track smarter metrics**  
   Move beyond total revenue. Monitor quarterly:  
   - DTC share of sales (aim for 75–80% by 2027)  
   - DTC full-price sales %  
   - DTC customer repeat purchases  
   - Margin gap between DTC and wholesale  

These moves will sustain growth, safeguard profits, and enhance our US brand position.

## Limitations & Next-Level Data Needs
Our dataset excels at revenue trends but lacks depth on customer motivations and long-term sustainability.  

To refine decisions, add these KPIs:

| Area | KPI / Metric | Simple Explanation | Source | Current Status |
|------|--------------|--------------------|--------|----------------|
| Brand Health | Brand Consideration | Is adidas top-of-mind for sportswear buys? | Brand surveys (e.g., YouGov, internal) | Not tracked |
| | Net Sentiment Score | Are online talks/reviews positive? | Social tools (e.g., Brandwatch) + reviews | Partially tracked |
| Customer Loyalty | Repeat Purchase Frequency | How often do DTC customers return in 12 months? | CRM (e.g., Salesforce, adidas database) | Basic data exists |
| | 12-Month Retention Rate | % of customers still buying after a year? | CRM | Not calculated |
| | Customer Lifetime Value (CLV) | Total expected profit per customer? | CRM + finance data | Early model only |
| Marketing Efficiency | Cost Per Acquisition (CPA) – DTC | Ad cost per new DTC customer? | Ad platforms (e.g., Google, Meta) + CRM | Tracked per platform, not consolidated |
| | Return on Ad Spend (ROAS) – DTC | Sales return per ad dollar? | Ad platforms + sales data | Tracked per campaign, not unified |
