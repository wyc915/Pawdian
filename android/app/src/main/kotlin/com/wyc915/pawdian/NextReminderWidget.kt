package com.wyc915.pawdian

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Shows the next reminder. The Flutter app writes the texts (already
 * localized) with home_widget whenever reminders change.
 */
class NextReminderWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.next_reminder_widget).apply {
                setTextViewText(R.id.widget_title, widgetData.getString("next_title", "Pawdian"))
                setTextViewText(R.id.widget_subtitle, widgetData.getString("next_subtitle", ""))
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
