$cutorder = New-UDPage -Name 'Cut Order' -Url '/cutorder/:orderId' -Content {
    
    $order = Get-Order -OrderId $orderId
    $Species = $order.Species
    $Shop = $order.SlotShop

    switch ($Species) {
        'Beef' {
            switch ($Shop) {
                'Don' { Show-DonBeefCutOrder -OrderId $orderId }
                'McConnell' { Show-McConnellBeefCutOrder -OrderId $orderId }
            }
        }

        'Hog' {
            switch ($Shop) {
                'Don' { Show-DonHogCutOrder -OrderId $orderId }
                'McConnell' { Show-McConnellHogCutOrder -OrderId $orderId }
            }
        }
    }
}