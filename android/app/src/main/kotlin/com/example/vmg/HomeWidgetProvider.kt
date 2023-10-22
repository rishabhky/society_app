package com.example.myappwidget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import com.example.vmg.R


class HomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // Update the TextView with "Hello"
            views.setTextViewText(R.id.widgetText, "Hello")

            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
