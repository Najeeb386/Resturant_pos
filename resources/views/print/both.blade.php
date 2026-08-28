@php
if (!function_exists('getBarcodeSVG')) {
    function getBarcodeSVG($code, $height = 36, $width = 2) {
        $patterns = [
            '0' => '101001101101', '1' => '110100101011', '2' => '101100101011', '3' => '110110010101',
            '4' => '101001101011', '5' => '110100110101', '6' => '101100110101', '7' => '101001011011',
            '8' => '110100101101', '9' => '101100101101', '*' => '100101101101'
        ];
        $codeStr = '*' . strtoupper((string)$code) . '*';
        $binary = '';
        for ($i = 0; $i < strlen($codeStr); $i++) {
            $c = $codeStr[$i];
            if (isset($patterns[$c])) {
                $binary .= $patterns[$c] . '0';
            }
        }
        $svgWidth = strlen($binary) * $width;
        $svg = "<svg width=\"{$svgWidth}\" height=\"{$height}\" viewBox=\"0 0 {$svgWidth} {$height}\" xmlns=\"http://www.w3.org/2000/svg\" style=\"margin: 0 auto; display: block;\">\n";
        $svg .= "  <rect width=\"100%\" height=\"100%\" fill=\"white\"/>\n";
        $x = 0;
        for ($i = 0; $i < strlen($binary); $i++) {
            if ($binary[$i] === '1') {
                $svg .= "  <rect x=\"{$x}\" y=\"0\" width=\"{$width}\" height=\"{$height}\" fill=\"black\"/>\n";
            }
            $x += $width;
        }
        $svg .= "</svg>";
        return $svg;
    }
}
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receipt & KOT - {{ $order->id }}</title>
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
        
        /* Thermal Printer Page Cut Divider */
        .cut-line {
            text-align: center;
            font-weight: bold;
            font-size: 11px;
            margin: 30px 0;
            border-top: 2px dashed #000;
            border-bottom: 2px dashed #000;
            padding: 10px 0;
            page-break-after: always;
        }

        /* KOT Styles */
        .kot-header h1 { margin: 0; font-size: 20px; text-transform: uppercase; border-bottom: 2px solid #000; padding-bottom: 5px; }
        .kot-details p { margin: 4px 0; font-size: 14px; }
        .kot-highlight { font-size: 16px; font-weight: bold; }
        .kot-items-table td.qty { width: 50px; text-align: center; font-weight: bold; font-size: 16px;}
        .kot-items-table td.item-name { font-size: 16px; font-weight: bold;}

        @media print {
            body { width: 100%; margin: 0; padding: 0; }
            .container { padding: 0; }
            .cut-line { page-break-after: always; }
        }
    </style>
</head>
<body onload="window.print();">
    <div class="container">
        <!-- ==================== PART 1: RETAIL RECEIPT ==================== -->
        <div class="header text-center mb-2">
            @if($restaurant->logo)
                <img src="{{ asset('storage/' . $restaurant->logo) }}" alt="{{ $restaurant->name }}" style="max-width: 180px; max-height: 75px; object-fit: contain; margin: 0 auto 6px auto; display: block;" />
            @else
                <h1>{{ $restaurant->name }}</h1>
            @endif
            <p>{{ $restaurant->address }}</p>
            @if($restaurant->phone) <p>PHONE : {{ $restaurant->phone }}</p> @endif
            @if($restaurant->gst_number) <p>GSTIN : {{ $restaurant->gst_number }}</p> @endif
        </div>

        <div class="text-center title">RETAIL INVOICE</div>

        <div class="details mb-2">
            <p>Date : {{ $order->created_at->format('d/m/Y, h:i A') }}</p>
            <p class="font-bold" style="font-size: 13px; text-transform: uppercase;">Bill No: #{{ $order->id }}</p>
            <p>Type: {{ ucfirst(str_replace('_', ' ', $order->order_type)) }}</p>
            <p class="font-bold">Payment Method: {{ str_replace('Payment via ', '', $order->notes ?? 'Cash') }}</p>
            <p>Payment Status: {{ ucfirst($order->payment_status) }}</p>
            @if($order->customer_name)
                <p class="font-bold mt-1">Customer: {{ $order->customer_name }}</p>
            @endif
            @if($order->customer_phone)
                <p class="font-bold">Phone: {{ $order->customer_phone }}</p>
            @endif
            @if($order->delivery_address)
                <p class="font-bold" style="margin-top: 4px; border: 1px dashed #000; padding: 4px;">Delivery Address:<br>{{ $order->delivery_address }}</p>
            @endif
            @if($order->table)
                <p>Table: {{ $order->table->name ?? $order->table->table_number }}</p>
            @endif
        </div>

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

        <!-- Barcode of Invoice/Order Number above Footer -->
        <div class="text-center mt-2 mb-2" style="margin-top: 15px; margin-bottom: 8px;">
            {!! getBarcodeSVG($order->id) !!}
            <p style="font-size: 10px; margin-top: 2px; font-weight: bold; letter-spacing: 1px;">#{{ sprintf('%06d', $order->id) }}</p>
        </div>

        <div class="header text-center mt-2">
            <p>*** THANK YOU ***</p>
            @if($restaurant->receipt_footer)
                <p>{{ $restaurant->receipt_footer }}</p>
            @endif
            <p style="font-size: 10px; font-weight: bold; margin-top: 10px; letter-spacing: 0.8px; text-transform: uppercase; color: #444;">
                Powered by {{ config('app.name', 'DineDesk') }}
            </p>
        </div>

        <!-- ==================== CUT DIVIDER ==================== -->
        <div class="cut-line">
            ------------------------------------------<br>
            ✂ - - - - CUT HERE (RECEIPT / KOT) - - - - ✂<br>
            ------------------------------------------
        </div>

        <!-- ==================== PART 2: KITCHEN ORDER TICKET (KOT) ==================== -->
        <div class="kot-header text-center mb-2">
            <h1>KOT</h1>
            <h2>Ticket #{{ $order->id }}</h2>
        </div>

        <div class="kot-details mb-2">
            <p>Date: {{ $order->created_at->format('d/m/Y, h:i A') }}</p>
            <p>Type: <span class="kot-highlight">{{ strtoupper(str_replace('_', ' ', $order->order_type)) }}</span></p>
            @if($order->customer_name)
                <p>Customer: <span class="kot-highlight">{{ $order->customer_name }}</span></p>
            @endif
            @if($order->customer_phone)
                <p>Phone: <span class="kot-highlight">{{ $order->customer_phone }}</span></p>
            @endif
            @if($order->delivery_address)
                <p style="border: 1px dashed #000; padding: 4px; margin-top: 4px;">Address:<br><span class="kot-highlight">{{ $order->delivery_address }}</span></p>
            @endif
            @if($order->table)
                <p>Table: <span class="kot-highlight">{{ $order->table->name ?? $order->table->table_number }}</span></p>
            @endif
        </div>

        <table class="items-table kot-items-table mb-2">
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
