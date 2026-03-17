package com.anonyname5.smartlist

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class SmartListCompactWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.smartlist_compact_widget).apply {
            val launchIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            setOnClickPendingIntent(R.id.widget_container_compact, launchIntent)

            setTextViewText(
                R.id.widget_compact_title,
                widgetData.getString("smartlist_title", "SmartList"),
            )
            setTextViewText(
                R.id.widget_compact_targets,
                "Today: ${widgetData.getString("smartlist_today_targets", "0")}",
            )
            setTextViewText(
                R.id.widget_compact_remaining,
                "Remain: ${widgetData.getString("smartlist_remaining", "RM0.00")}",
            )
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
