import time

from google.cloud import pubsub

from .project import Info


class PClient(Info, pubsub.PublisherClient):
    """PubSub publisher client"""

    def get_topics(self):
        """Get topics of current project"""
        return self.list_topics(self.project_path)

    @staticmethod
    def _ensure_bytes(message):
        if isinstance(message, bytes):
            return message
        if isinstance(message, str):
            return message.encode("utf-8")
        raise ValueError("Message has to be either str or encoded utf-8")

    @property
    def project_path(self):
        return super().project_path(self.project_id)

    def topic_path(self, topic_name):
        return super().topic_path(self.project_id, topic_name)

    def publish_messages(self, topic_name, messages):
        """Publishes multiple messages to a Pub/Sub topic.

        messages: list(str)
        """
        # The `topic_path` method creates a fully qualified identifier
        # in the form `projects/{project_id}/topics/{topic_name}`
        topic_path = self.topic_path(topic_name)

        for msg in messages:
            # When you publish a message, the client returns a future.
            future = super().publish(topic_path, data=self._ensure_bytes(msg))
            print(future.result())


class SClient(Info, pubsub.SubscriberClient):
    """PubSub subscriber client"""

    def subscription_path(self, subscription_name):
        return super().subscription_path(self.project_id, subscription_name)

    def receive_messages(self, subscription_name):
        """Receives messages from a pull subscription."""
        # The `subscription_path` method creates a fully qualified identifier
        # in the form `projects/{project_id}/subscriptions/{subscription_name}`
        subscription_path = self.subscription_path(subscription_name)

        def callback(message):
            print('Received message: {}'.format(message))
            message.ack()

        super().subscribe(subscription_path, callback=callback)

        # The subscriber is non-blocking. We must keep the main thread from
        # exiting to allow it to process messages asynchronously in the background.
        print('Listening for messages on {}'.format(subscription_path))
        while True:
            time.sleep(60)


# demo code
def list_project_topics(client):
    for topic in client.get_topics():
        print(topic)


def publish_to(client, topic_name):
    messages = (f"Message number {n}" for n in range(1, 10))
    client.publish_messages(topic_name, messages)


if __name__ == "__main__":
    publisher = PClient()
    list_project_topics(publisher)
    # publish_to(publisher, "tempo-test")

    # client = SClient()
    # client.receive_messages("laptop")
