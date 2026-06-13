<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receipt - {{ $order->id }}</title>
    <style>
        body {
            font-family: 'Courier New', Courier, monospace;
            margin: 0;
            padding: 0;
            background-color: #fff;
            color: #000;
            font-size: 12px;
            width: 300px; /* Thermal printer typical width 80mm */
        }
        .container {
            padding: 10px;
            margin: 0 auto;
        }
        .text-center { text-align: center; }
        .text-right { text-align: right; }
        .text-left { text-align: left; }
        .font-bold { font-weight: bold; }
        .mb-1 { margin-bottom: 5px; }
        .mb-2 { margin-bottom: 10px; }
        .mt-2 { margin-top: 10px; }
        .border-top { border-top: 1px dashed #000; }
        .border-bottom { border-bottom: 1px dashed #000; }
        .py-1 { padding: 5px 0; }
        
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 3px 0; vertical-align: top; }
        th { border-bottom: 1px dashed #000; border-top: 1px dashed #000; text-align: left;}
        
        .header h1 { margin: 0; font-size: 16px; text-transform: uppercase; }
        .header p { margin: 2px 0; font-size: 11px; }
        
        .title { text-transform: uppercase; font-weight: bold; font-size: 14px; margin: 10px 0; }
        
        .details p { margin: 2px 0; font-size: 11px; }

        .items-table td.qty { width: 40px; text-align: center; }
        .items-table td.amt { width: 60px; text-align: right; }

        .totals-table td { font-size: 12px; }
        .totals-table td:last-child { text-align: right; }

        .grand-total { font-size: 14px; font-weight: bold; border-top: 1px dashed #000; border-bottom: 1px dashed #000; padding: 5px 0; margin-top: 5px; }
        
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
            <h1>{{ $restaurant->name }}</h1>
            <p>{{ $restaurant->address }}</p>
            @if($restaurant->phone) <p>PHONE : {{ $restaurant->phone }}</p> @endif
            @if($restaurant->gst_number) <p>GSTIN : {{ $restaurant->gst_number }}</p> @endif
        </div>

        <div class="text-center title">Retail Invoice</div>

        <!-- Order Details -->
        <div class="details mb-2">
            <p>Date : {{ $order->created_at->format('d/m/Y, h:i A') }}</p>
            @if($order->customer_name)
                <p class="font-bold mt-2">{{ $order->customer_name }}</p>
            @endif
            <p>Bill No: {{ $order->id }}</p>
            <p>Type: {{ ucfirst($order->order_type) }}</p>
            <p>Payment Status: {{ ucfirst($order->payment_status) }}</p>
            @if($order->table)
                <p>Table: {{ $order->table->name }}</p>
            @endif
        </div>

        <!-- Items -->
        <table class="items-table mb-2">
            <thead>
                <tr>
                    <th>Item</th>
                    <th class="text-center">Qty</th>
                    <th class="text-right">Amount</th>
                </tr>
            </thead>
            <tbody>
                @foreach($order->orderItems as $item)
                <tr>
                    <td>{{ $item->menuItem->name }}</td>
                    <td class="qty">{{ $item->quantity }}</td>
                    <td class="amt">{{ $restaurant->currency_symbol }}{{ number_format($item->price * $item->quantity, 2) }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>

        <!-- Totals -->
        <table class="totals-table">
            <tr>
                <td>Sub Total</td>
                <td>{{ $restaurant->currency_symbol }}{{ number_format($order->subtotal, 2) }}</td>
            </tr>
            @if($order->tax > 0)
            <tr>
                <td>Tax ({{ $restaurant->tax_percentage }}%)</td>
                <td>{{ $restaurant->currency_symbol }}{{ number_format($order->tax, 2) }}</td>
            </tr>
            @endif
            @if($order->delivery_fee > 0)
            <tr>
                <td>Delivery Fee</td>
                <td>{{ $restaurant->currency_symbol }}{{ number_format($order->delivery_fee, 2) }}</td>
            </tr>
            @endif
        </table>

        <div class="grand-total">
            <table style="width: 100%">
                <tr>
                    <td>TOTAL</td>
                    <td class="text-right">{{ $restaurant->currency_symbol }}{{ number_format($order->total, 2) }}</td>
                </tr>
            </table>
        </div>

        <div class="header text-center mt-2">
            <p>*** THANK YOU ***</p>
            @if($restaurant->receipt_footer)
                <p>{{ $restaurant->receipt_footer }}</p>
            @endif
        </div>
    </div>
</body>
</html>
