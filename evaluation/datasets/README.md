{
  "dataset_id": "AI-AGENT-SYNTHETIC-BASELINE",
  "dataset_version": "1.0.0",
  "description": "Synthetic customer support data shared across the Python, LangChain/LangGraph, and Rust implementations.",
  "reference_date": "2026-10-31",
  "currency": "CAD",
  "data_classification": "INTERNAL",
  "synthetic_only": true,
  "customers": [
    {
      "customer_id": "CUST-SYN-001",
      "name": "Alex Morgan",
      "email": "alex.morgan@example.test",
      "phone": "+1-555-0101",
      "customer_tier": "STANDARD",
      "account_status": "ACTIVE"
    },
    {
      "customer_id": "CUST-SYN-002",
      "name": "Jordan Lee",
      "email": "jordan.lee@example.test",
      "phone": "+1-555-0102",
      "customer_tier": "PREMIUM",
      "account_status": "ACTIVE"
    },
    {
      "customer_id": "CUST-SYN-003",
      "name": "Taylor Smith",
      "email": "taylor.smith@example.test",
      "phone": "+1-555-0103",
      "customer_tier": "STANDARD",
      "account_status": "ACTIVE"
    },
    {
      "customer_id": "CUST-SYN-004",
      "name": "Casey Brown",
      "email": "casey.brown@example.test",
      "phone": "+1-555-0104",
      "customer_tier": "STANDARD",
      "account_status": "ACTIVE"
    }
  ],
  "products": [
    {
      "product_id": "PROD-SYN-001",
      "name": "Wireless Headphones",
      "category": "ELECTRONICS",
      "unit_price": 89.99,
      "currency": "CAD"
    },
    {
      "product_id": "PROD-SYN-002",
      "name": "Mechanical Keyboard",
      "category": "ELECTRONICS",
      "unit_price": 129.99,
      "currency": "CAD"
    },
    {
      "product_id": "PROD-SYN-003",
      "name": "USB-C Charging Cable",
      "category": "ACCESSORIES",
      "unit_price": 19.99,
      "currency": "CAD"
    },
    {
      "product_id": "PROD-SYN-004",
      "name": "Portable Monitor",
      "category": "ELECTRONICS",
      "unit_price": 199.99,
      "currency": "CAD"
    },
    {
      "product_id": "PROD-SYN-005",
      "name": "Laptop Stand",
      "category": "ACCESSORIES",
      "unit_price": 59.99,
      "currency": "CAD"
    }
  ],
  "orders": [
    {
      "order_id": "ORD-SYN-001",
      "customer_id": "CUST-SYN-001",
      "order_status": "DELIVERED",
      "ordered_at": "2026-10-10T10:00:00Z",
      "delivered_at": "2026-10-15T14:00:00Z",
      "items": [
        {
          "product_id": "PROD-SYN-001",
          "quantity": 1,
          "unit_price": 89.99
        }
      ],
      "total_amount": 89.99,
      "currency": "CAD"
    },
    {
      "order_id": "ORD-SYN-002",
      "customer_id": "CUST-SYN-002",
      "order_status": "DELIVERED",
      "ordered_at": "2026-08-25T09:00:00Z",
      "delivered_at": "2026-09-01T15:30:00Z",
      "items": [
        {
          "product_id": "PROD-SYN-002",
          "quantity": 1,
          "unit_price": 129.99
        }
      ],
      "total_amount": 129.99,
      "currency": "CAD"
    },
    {
      "order_id": "ORD-SYN-003",
      "customer_id": "CUST-SYN-003",
      "order_status": "DELIVERED",
      "ordered_at": "2026-10-01T11:00:00Z",
      "delivered_at": "2026-10-05T13:00:00Z",
      "items": [
        {
          "product_id": "PROD-SYN-003",
          "quantity": 2,
          "unit_price": 19.99
        }
      ],
      "total_amount": 39.98,
      "currency": "CAD"
    },
    {
      "order_id": "ORD-SYN-004",
      "customer_id": "CUST-SYN-004",
      "order_status": "SHIPPED",
      "ordered_at": "2026-10-25T12:00:00Z",
      "delivered_at": null,
      "items": [
        {
          "product_id": "PROD-SYN-004",
          "quantity": 1,
          "unit_price": 199.99
        }
      ],
      "total_amount": 199.99,
      "currency": "CAD"
    },
    {
      "order_id": "ORD-SYN-005",
      "customer_id": "CUST-SYN-001",
      "order_status": "DELIVERED",
      "ordered_at": "2026-10-20T08:00:00Z",
      "delivered_at": "2026-10-23T16:00:00Z",
      "items": [
        {
          "product_id": "PROD-SYN-005",
          "quantity": 1,
          "unit_price": 59.99
        },
        {
          "product_id": "PROD-SYN-003",
          "quantity": 1,
          "unit_price": 19.99
        }
      ],
      "total_amount": 79.98,
      "currency": "CAD"
    }
  ],
  "tickets": [
    {
      "ticket_id": "TKT-SYN-001",
      "customer_id": "CUST-SYN-001",
      "order_id": "ORD-SYN-001",
      "subject": "Wireless headphones refund request",
      "message": "I received my wireless headphones recently and would like to request a refund.",
      "created_at": "2026-10-25T10:00:00Z",
      "status": "OPEN",
      "priority": "NORMAL"
    },
    {
      "ticket_id": "TKT-SYN-002",
      "customer_id": "CUST-SYN-002",
      "order_id": "ORD-SYN-002",
      "subject": "Keyboard refund request",
      "message": "I would like to return the mechanical keyboard from my order.",
      "created_at": "2026-10-20T09:30:00Z",
      "status": "OPEN",
      "priority": "NORMAL"
    },
    {
      "ticket_id": "TKT-SYN-003",
      "customer_id": "CUST-SYN-003",
      "order_id": "ORD-SYN-003",
      "subject": "Damaged charging cable",
      "message": "The charging cable arrived damaged. What should I do to request a refund?",
      "created_at": "2026-10-12T11:00:00Z",
      "status": "OPEN",
      "priority": "HIGH"
    },
    {
      "ticket_id": "TKT-SYN-004",
      "customer_id": "CUST-SYN-004",
      "order_id": "ORD-SYN-004",
      "subject": "Order delivery status",
      "message": "Can you tell me when my portable monitor will arrive?",
      "created_at": "2026-10-29T14:00:00Z",
      "status": "OPEN",
      "priority": "NORMAL"
    },
    {
      "ticket_id": "TKT-SYN-005",
      "customer_id": "CUST-SYN-001",
      "order_id": "ORD-SYN-005",
      "subject": "Missing order information",
      "message": "I need help with my recent purchase, but I cannot find the order confirmation.",
      "created_at": "2026-10-27T16:00:00Z",
      "status": "OPEN",
      "priority": "NORMAL"
    },
    {
      "ticket_id": "TKT-SYN-006",
      "customer_id": "CUST-SYN-002",
      "order_id": null,
      "subject": "General support request",
      "message": "I have a question about your return process. Can someone explain the policy?",
      "created_at": "2026-10-30T12:00:00Z",
      "status": "OPEN",
      "priority": "NORMAL"
    }
  ],
  "business_policies": [
    {
      "policy_id": "POL-SYN-001",
      "policy_name": "Standard Return Window",
      "policy_version": "v1",
      "policy_type": "RETURN_WINDOW",
      "return_window_days": 30,
      "return_window_unit": "CALENDAR_DAYS",
      "status": "ACTIVE"
    },
    {
      "policy_id": "POL-SYN-002",
      "policy_name": "Refund Transaction Cap",
      "policy_version": "v1",
      "policy_type": "REFUND_LIMIT",
      "maximum_refund_amount": 100.00,
      "currency": "CAD",
      "status": "ACTIVE"
    },
    {
      "policy_id": "POL-SYN-003",
      "policy_name": "Damaged Goods Verification",
      "policy_version": "v1",
      "policy_type": "DAMAGE_VERIFICATION",
      "image_verification_required": true,
      "status": "ACTIVE"
    }
  ]
}
