import SwiftUI

/// Date window at 3 o'clock showing the day of the month.
struct DateSubdialView: View {
    let watchDiameter: CGFloat
    let date: Date

    private var offset: CGFloat {
        watchDiameter * WatchConstants.subdialOffset
    }
    private var windowWidth: CGFloat { watchDiameter * 0.10 }
    private var windowHeight: CGFloat { watchDiameter * 0.08 }

    var body: some View {
        let day = AngleCalculations.dayOfMonth(from: date)

        ZStack {
            // White background
            RoundedRectangle(cornerRadius: 1)
                .fill(WatchConstants.dateWhite)
                .frame(width: windowWidth, height: windowHeight)

            // Silver border
            RoundedRectangle(cornerRadius: 1)
                .stroke(WatchConstants.silverDark, lineWidth: 0.5)
                .frame(width: windowWidth, height: windowHeight)

            // Day number
            Text("\(day)")
                .font(.custom(WatchConstants.romanFontName,
                              size: watchDiameter * WatchConstants.fontValueLg))
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .offset(x: offset)
    }
}
