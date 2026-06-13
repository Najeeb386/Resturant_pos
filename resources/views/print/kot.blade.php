<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KOT - {{ $order->id }}</title>
    <style>
        body {
            font-family: 'Courier New', Courier, monospace;
            margin: 0;
            padding: 0;
            background-color: #fff;
            color: #000;
            font-size: 14px; /* Larger font for kitchen */
            width: 300px;
        }
        .container {
            padding: 10px;
            margin: 0 auto;
        }
        .text-center { text-align: center; }
        .text-right { text-align: right; }
        .font-bold { font-weight: bold; }
        .mb-2 { margin-bottom: 10px; }
        
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 5px 0; vertical-align: top; }
        th { border-bottom: 2px dashed #000; border-top: 2px dashed #000; text-align: left;}
        
        .header h1 { margin: 0; font-size: 20px; text-transform: uppercase; border-bottom: 2px solid #000; padding-bottom: 5px; }
        
        .details p { margin: 4px 0; font-size: 14px; }
        .highlight { font-size: 16px; font-weight: bold; }

        .items-table td.qty { width: 50px; text-align: center; font-weight: bold; font-size: 16px;}
        .items-table td.item-name { font-size: 16px; font-weight: bold;}
        
        @media print {
            body { width: 100%; margin: 0; padding: 0; }
            .container { padding: 0; }
        }
    </style>
</head>
<body onload="window.print();">
    <div class="container">
        <!-- Header -->
        <div class="header text-center mb-2">
            <h1>KOT</h1>
            <h2>Ticket #{{ $order->id }}</h2>
        </div>

        <!-- Order Details -->
        <div class="details mb-2">
            <p>Date: {{ $order->created_at->format('d/m/Y, h:i A') }}</p>
            <p>Type: <span class="highlight">{{ strtoupper($order->order_type) }}</span></p>
            @if($order->table)
                <p>Table: <span class="highlight">{{ $order->table->name }}</span></p>
            @endif
        </div>

        <!-- Items -->
        <table class="items-table mb-2">
            <thead>
                <tr>
                    <th class="text-center">Qty</th>
                    <th>Item</th>
                </tr>
            </thead>
            <tbody>
                @foreach($order->orderItems as $item)
                <tr>
                    <td class="qty">{{ $item->quantity }} x</td>
                    <td class="item-name">{{ $item->menuItem->name }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>

        @if($order->notes)
            <div style="border: 1px dashed #000; padding: 5px; margin-top: 10px;">
                <strong>Notes:</strong><br>
                {{ $order->notes }}
            </div>
        @endif
        
        <div class="text-center mt-2" style="margin-top: 20px; border-top: 1px dashed #000; padding-top: 5px;">
            <p style="font-size: 12px;">Kitchen Copy</p>
        </div>
    </div>
</body>
</html>
